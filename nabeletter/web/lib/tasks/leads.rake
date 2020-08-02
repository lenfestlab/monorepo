namespace :leads do

  desc "import latest FB leads"
  task import: :environment do
    newsletter = Newsletter.first
    csv = CSV.read("./lib/tasks/leads.csv", {headers: true})
    ap csv
    csv.each do |entry|
      ap entry
      email = entry["Email"]
      Subscription.create(newsletter: newsletter, email_address: email)
    end
  end

end
