require "json"
require "debug"
def itunes_data
  File.read("itunes-data.json.txt")
end
debugger
albums = {}
# foo = JSON.parse(itunes_data)
clean_json = itunes_data().undump

JSON.parse(itunes_data).each do |item|
  key = item["album"]
  if !albums[key]
    albums[key] = item
  end
  # debugger
  albums[key]["play_count"] < item["play_count"] ? albums[key]["play_count"] = item["play_count"] : albums[key]["play_count"]
end
puts albums
