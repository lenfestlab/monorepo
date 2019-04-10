namespace :adapt do

  desc "import 2018 guide"
  task images: :environment do

    Category.all.each do |category|
      category.image_urls.each do |url|
        image = Image.find_or_create_by(url: url)
        category.photos << image
        category.save!
      end
    end

    Post.all.each do |post|
      post.images_data.each do |data|
        image_attrs = data.slice(*%w{ url caption credit }).symbolize_keys
        url = image_attrs[:url]
        image =
          Image.find_by_url(url) ||
          Image.create!(image_attrs)
        post.photos << image
        post.save!
      end
    end

  end
end


