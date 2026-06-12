class WeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform
    entries = HobbyEntry.where(created_at: 1.week.ago..)
                        .includes(:user)
                        .order(created_at: :desc)

    return if entries.empty?

    User.find_each do |user|
      WeeklyDigestMailer.digest(user, entries).deliver_now
    end
  end
end
