use framework "Foundation"

tell application "Music"
	set albumData to {}
	set allTracks to every track of library playlist 1
	repeat with t in allTracks
		set albumName to album of t
		set artistName to artist of t
		set genreName to genre of t
		set composerName to composer of t
		set playCount to played count of t
		
		if albumName is not missing value and artistName is not missing value then
			-- Create the JSON-like structure, properly escaping quotes and special characters
			set json_entry to "{\"album\": \"" & albumName & "\", \"artist\": \"" & artistName & "\", \"genre\": \"" & genreName & "\", \"composer\": \"" & composerName & "\", \"play_count\": " & playCount & "},"
			copy json_entry to end of albumData
		end if
	end repeat
	
	-- Join all JSON entries into a valid JSON array
	set json_output to "[" & (albumData as text) & "]"
	return json_output
end tell