class HabitMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.habit_mailer.reminder.subject
  #
  def habit_reminder
    @habit = params[:habit]
    @user = @habit.created_by

    mail(
      to: email_address_with_name(@user.email, @user.name),
      from: email_address_with_name(Jumpstart.config.support_email, @user.name),
      subject: t(".subject", habit: @habit.title)
    )
  end
end
