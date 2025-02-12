import subprocess
import json
import base64
import os

def itunes_data():
    data = '''
    "[{"Analogue", "A-Ha", "Pop", "Medium", 13}, {"American Flyers", "Glenn Shorrock", "Rock", "Hard", 1}, {"American Flyers", "Lee Ritenour & Greg Mathieson", "Rock", "Hard", 2}, {"American Flyers", "Danny Hutton", "Rock", "Hard", 1}, {"American Flyers", "Chris Isaak", "Rock", "Hard", 0}, {"American Flyers", "Creedence Clearwater Revival", "Rock", "Hard", 0}]"
    '''
    return data

# Run AppleScript
def get_itunes_data():
    script = '''
    use framework "Foundation"

    tell application "Music"
        set albumData to {}
        set allTracks to every track of playlist "Test"
        repeat with t in allTracks
            set albumName to album of t
            set artistName to artist of t
            set genreName to genre of t
            set composerName to composer of t
            set playCount to played count of t

            if albumName is not missing value and artistName is not missing value then
                -- Create the JSON-like structure, properly escaping quotes and special characters
                set json_entry to "{\"album\": \"" & albumName & "\", \"artist\": \"" & artistName & "\", \"genre\": \"" & genreName & "\", \"composer\": \"" & composerName & "\", \"play_count\": " & playCount & "}"
                copy json_entry to end of albumData
            end if
        end repeat

        -- Join all JSON entries into a valid JSON array
        set json_output to "[" & (albumData as text) & "]"
        return json_output
    end tell
    '''
    process = subprocess.run(["osascript", "-e", script], capture_output=True, text=True)
    # print(process.stdout)
    return json.loads(process.stdout.strip())  

# Run and print the output
print(f"itunes data???: #{itunes_data()}")
itunes_data = json.loads(itunes_data())
print(json.dumps(itunes_data, indent=4))

# # Extract album artwork
def get_album_artwork(album):
    artwork_path = "/tmp/album_artwork.png"
    try:
        command = f'''osascript -e 'tell application "Music" to get artwork of (some track whose album is "{album}")' '''
        subprocess.run(["osascript", "-e", command], check=True)
        with open(artwork_path, "rb") as img_file:
            return base64.b64encode(img_file.read()).decode("utf-8")
    except Exception:
        return None  # Return None if artwork is missing

# # Convert AppleScript output to JSON
# def save_album_data():
#     albums = get_album_data()
#     print(f"album size?: #{len(albums)}")
#     formatted_albums = []
    
#     for album in albums:
#         formatted_albums.append({
#             "album_title": album[0],
#             "artist": album[1],
#             "genre": album[2],
#             "composer": album[3],
#             "play_count": album[4],
#             "album_artwork": get_album_artwork(album[0])
#         })
    
#     with open("itunes_albums.json", "w") as f:
#         json.dump(formatted_albums, f, indent=4)

#     print("Exported album data to itunes_albums.json")

# # Run script
# save_album_data()
