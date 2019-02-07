raise "attempted to seed prod!" if Rails.env == "production"

dir = ENV["ADMIN_DB_SEED_DIR"]
file = File.open("#{dir}/posts.yml")
data = YAML::load(file)["posts"]

data.each do |post_data|
  places_data = post_data.delete("places")
  post = Post.create(post_data)
  places_data.each do |place_data|
    post.places.create(place_data)
  end
end
