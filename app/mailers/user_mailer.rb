class UserMailer < ApplicationMailer
  def new_company_user_email(new_user)
    @user = new_user
    mail(to: ENV['MAIL_FROM'], subject: t('users.mailer.newcompanyuseremail.subject'))  do |format|
      format.html { render layout: 'mailer', template: 'users/mailer/new_company_user_email' }
    end
  end

  def new_company_user_pending_email(new_user)
    @user = new_user
    mail(to: @user.email, subject: t('users.mailer.newcompanyuserpendingemail.subject'))  do |format|
      format.html { render layout: 'mailer', template: 'users/mailer/new_company_user_pending_email' }
    end
  end

  def welcome_company_user_email(updated_user)
    @user = updated_user
    mail(to: @user.email, subject: t('users.mailer.welcomecompanyuseremail.subject'))  do |format|
      format.html { render layout: 'mailer', template: 'users/mailer/welcome_company_user_email' }
    end
  end
end
