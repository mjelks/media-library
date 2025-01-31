# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
# "Album", "CD", "mp3", "bluray", "DVD"
media_types = [
  { name: "Album", description: "Vinyls and the vintage Record stuff" },
  { name: "CD", description: "Something recorded on something plastic, like, I don't know ... A DISC???!!" },
  { name: "mp3", description: "Something aquired via iTunes / Amazon / online mp3 purchase (aka stored in the digital realm only)" },
  { name: "DVD", description: "Something recorded on something plastic, with video as well, like, I don't know ... A DISC???!!" },
  { name: "Bluray", description: "Like a DVD, with less vasoline filter" }
]
media_types.each do |media_type|
  MediaType.find_or_create_by!(name: media_type[:name], description: media_type[:description])
end
