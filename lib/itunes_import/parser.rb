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

    MEDIA_TYPE_CD  = "CD"
    MEDIA_TYPE_MP3 = "mp3"

    # Path to your iTunes/Music library XML file
    # usage: `ItunesImport::Parser.parse` <== assumes Library.xml is in the current dir
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

        if track_info["Bit Rate"].to_i > 192
          aggregated_albums[key]["media_type"] = MEDIA_TYPE_MP3
        end

        # Aggregate play counts and track count
        aggregated_albums[key]["play_count"] = track_info["Play Count"].to_i > aggregated_albums[key]["play_count"].to_i ? track_info["Play Count"].to_i : aggregated_albums[key]["play_count"].to_i
        aggregated_albums[key]["track_count"] += 1
      end

      # Convert to JSON and save to file
      json_output = JSON.pretty_generate(aggregated_albums.values)

      output_path = File.join(__dir__, "aggregated_music_library.json")
      File.write(output_path, json_output)

      puts "JSON file generated: #{output_path}"

      total_albums = aggregated_albums.size

      puts "total albums generated from parse: #{total_albums}"
    end

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
          artist = Artist.find_or_create_by(name: album["artist"])
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

    def get_album_art
      json = load_json_music_data
      puts puts "total albums generated from parse: #{json.size}"
      json.each do |album|
        puts "artist: #{album["artist"]} | album: #{album["album"]} | file_location: #{album["location"]}"
      end
      # stdout, _stderr, _status = Open3.capture3("exiftool -b -Picture '#{file_path}'")
      # stdout if stdout && !stdout.empty?
    end

    def load_json_music_data(json_library_file = "aggregated_music_library.json")
      file = File.open File.join(__dir__, json_library_file)
      JSON.load(file)
    end
  end
end
