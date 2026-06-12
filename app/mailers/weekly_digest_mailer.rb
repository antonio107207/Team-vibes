class WeeklyDigestMailer < ApplicationMailer
  def digest(user, entries)
    @user = user
    @entries = entries
    @week_start = 1.week.ago.strftime("%d.%m")
    @week_end = Date.today.strftime("%d.%m.%Y")
    mail(to: @user.email, subject: "✨ Team Vibes: що нового за тиждень (#{@week_start}–#{@week_end})")
  end
end
