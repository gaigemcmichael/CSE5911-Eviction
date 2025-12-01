namespace :messages do
  desc "Check for unread messages and send email notifications"
  task check_unread: :environment do
    puts "Checking for unread messages..."
    UnreadMessageNotificationJob.perform_now
    puts "Done!"
  end
end
