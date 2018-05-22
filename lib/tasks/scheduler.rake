namespace :log do
  desc 'This task is called by the Heroku scheduler add-on'
  task deadline: :environment do
    Card.create_due_date_notification_logs!
  end
end
