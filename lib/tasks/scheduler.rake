desc 'This task is called by the Heroku scheduler add-on'
task create_logs_task: :environment do
  Card.create_due_date_notification_logs!
end
