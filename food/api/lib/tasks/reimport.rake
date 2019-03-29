namespace :seed do

  desc "import 2018 guide"
  task reimport: :environment do
    # drop non-use data
    [Bookmark, Category, Place, Post].each { |klass| klass.destroy_all }
    # reimport
    %w{
    seed:guide
    seed:burbs
    }.each {|name|
      Rake::Task[name].invoke
    }
  end
end


