namespace :seed do

  desc "import 2018 guide"
  task reimport: :environment do
    # drop non-use data
    klasses = [Bookmark, Category, Place, Post]
    klasses.each { |klass| klass.destroy_all } # trigger callbacks
    klasses.each do |klass|
      table_name = klass.to_s.tableize
      klass.connection.execute("TRUNCATE #{table_name} RESTART IDENTITY")
    end
    # reimport
    %w{
    seed:guide
    seed:burbs
    }.each {|name|
      Rake::Task[name].invoke
    }
  end
end


