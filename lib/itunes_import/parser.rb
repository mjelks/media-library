module ItunesImport
  class Parser
    # first we require the .xml file to be exported via Music.app
    # read file:
    # foreach track, build up a list of artist + album_names (with the appopriate meta data we'll need for baseline db entries)
    # so we can cleanly do another check for artwork, we'll take the hash built above and loop again, performing the following
    # foreach artist+album, run exiftool on track01 information to gather embedded artwork info
    #   - exiftool "01 Celice.mp3"| grep "Picture Format" ==> "PNG" (capture the file extension )
    #   - exiftool -b -Picture "01 Celice.mp3" > ~/Desktop/A-Ha_Analogue.PNG
    #
    #
    require "open3"
    require "plist"
    require "json"
    require "cgi"
    require "mimemagic"

    MEDIA_TYPE_CD  = "CD"
    MEDIA_TYPE_MP3 = "mp3"
    FS_PREFIX = "/mnt/volumes/Thunder18/NOTIMEMACHINE"
    JSON_MUSIC_DATA_FILENAME="aggregated_music_library.full.json"

    # Path to your iTunes/Music library XML file
    # usage: `ItunesImport::Parser.parse` <== assumes Library.xml is in the current dir
    # STEP 1
    def self.parse(xml_file = "Library.xml")
      xml_path = File.join(__dir__, xml_file)

      # Load and parse the XML file
      plist = Plist.parse_xml(xml_path)

      # Extract track information
      tracks = plist["Tracks"]

      aggregated_albums = {}

      tracks.each do |_, track_info|
        artist = track_info["Artist"]
        album = track_info["Album"]

        # Skip tracks with missing artist or album
        next if album.nil? || album.strip.empty?

        album = album.titleize
        artist = artist.titleize
        key = "#{album}"

        # Initialize album entry if not present
        aggregated_albums[key] ||= {
          "album" => album,
          "artist" => artist,
          "genre" => track_info["Genre"] || "Unknown Genre",
          "composer" => track_info["Composer"] || "Unknown Composer",
          "play_count" => track_info["Play Count"],  # Sum of play counts for all tracks in the album, I'll init with the first one we pickup
          "location" => track_info["Location"],
          "date_added" => track_info["Date Modified"], # in the library.xml, it appears that Date Modified is roughly the date files were added to iTunes library
          "media_type" => MEDIA_TYPE_CD,
          "track_count" => 0   # Count of tracks per album, init to 0 while we loop through
        }

        # when I did my encoding back in the day of CDs, I never went past 192kbps I believe
        if track_info["Bit Rate"].to_i > 192
          aggregated_albums[key]["media_type"] = MEDIA_TYPE_MP3
        end

        # Aggregate play counts and track count
        aggregated_albums[key]["play_count"] = track_info["Play Count"].to_i > aggregated_albums[key]["play_count"].to_i ? track_info["Play Count"].to_i : aggregated_albums[key]["play_count"].to_i
        aggregated_albums[key]["track_count"] += 1
      end

      # Convert to JSON and save to file
      json_output = JSON.pretty_generate(aggregated_albums.values)

      output_path = File.join(__dir__, JSON_MUSIC_DATA_FILENAME)
      File.write(output_path, json_output)

      puts "JSON file generated: #{output_path}"

      total_albums = aggregated_albums.size

      puts "total albums generated from parse: #{total_albums}"
    end

    # STEP 2
    def import_media
      json = load_json_music_data

      # gets you this:  {"Album" => 6, "CD" => 7, "mp3" => 8, "DVD" => 9, "Bluray" => 10}
      media_types = MediaType.all.map { |mt| [ mt.name, mt.id ] }.to_h

      # if we need to truncate and start over:
      # sqlite3 storage/development.sqlite3
      # DELETE FROM media_items;
      # DELETE FROM SQLITE_SEQUENCE WHERE name='media_items';

      json.each do |album|
        begin
          artist = Artist.find_or_create_by(name: album["artist"].titleize)
          MediaItem.find_or_create_by(
            title: album["album"],
            artist_id: artist.id,
            media_type_id: media_types[album["media_type"]],
            play_count: album["play_count"].to_i,
            track_count: album["track_count"].to_i
          )
        rescue => e
          # Log the error message
          Rails.logger.error("Error inserting media for album '#{album["title"]}': #{e.message}")
          # Optionally log the full backtrace for debugging
          Rails.logger.error(e.backtrace.join("\n"))
        end
      end
    end

    # STEP 3
    def import_album_art
      json = load_json_music_data
      puts puts "total albums generated from parse: #{json.size}"
      json.each do |album|
        # puts "artist: #{album["artist"]} | album: #{album["album"]} | file_location: #{album["location"]}"
        next if location_missing?(album)
        album_path = CGI.unescape(album["location"].sub("file:///Volumes/media", FS_PREFIX))
        stdout = get_image_data(album_path)
        media_item = get_existing_media_item(album)
        attach_artwork(media_item, stdout, album)
      end
    end

    ### HELPER METHODS
    def location_missing?(album)
      album["location"].blank? ? true : false
    end


    def get_existing_media_item(album)
      MediaItem.joins(:artist).where(artist: { name: album["artist"].try(:titleize) }).where(title: album["album"].try(:titleize)).first
    end

    def attach_artwork(media_item, binary_stdout, album)
      return if !media_item || !binary_stdout
      # Get mime type from the binary content (assuming `stdout` is binary data)
      mime_type = MimeMagic.by_magic(binary_stdout).to_s
      formatted_name = "#{album["album"]} cover art".parameterize(separator: "_")
      # puts "formatted name: #{formatted_name}"
      filename = "#{formatted_name}.#{mime_type.split('/').last}" # This will give you 'cover_art.jpg' or 'cover_art.png' depending on mime type
      media_item.artwork.attach(io: StringIO.new(binary_stdout), filename: filename, content_type: mime_type)
    end

    def get_image_data(album_path)
      # Open3.capture3("exiftool '#{album_path}'")
      # stdout, _stderr, _status = Open3.capture3("exiftool -b -CoverArt '#{album_path}'")
      stdout, stderr, status = Open3.capture3("exiftool", "-b", "-CoverArt", "-Picture", album_path)
      if stdout && !stdout.empty?
        stdout
      else
        puts "stderr: #{stderr}"
        puts "stdout: #{stdout}"
        puts "status of get_image_data for #{album_path} on stdout failure/blankitude: #{status.inspect}"
      end
    end

    def load_json_music_data
      file = File.open File.join(__dir__, JSON_MUSIC_DATA_FILENAME)
      JSON.load(file)
    end
  end
end
