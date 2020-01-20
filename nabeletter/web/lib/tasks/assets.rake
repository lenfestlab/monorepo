# NOTE: stub out rake task Heroku calls on every deploy, else:
# rake aborted!
# remote:        Don't know how to build task 'assets:clean' (See the list
# of available tasks with `rake --tasks`)
# remote:        Did you mean?  assets:precompile

namespace :assets do

  desc "Proxy webpacker:clean, equivalent of `rake assets:clean`"
  task clean: :environment do
    Rake::Task["webpacker:clean"].invoke
  end

end
