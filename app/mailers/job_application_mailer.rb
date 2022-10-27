class JobApplicationMailer < ApplicationMailer
  def company_with_bcc_email(job_application)
    @job_application = job_application
    @job = @job_application.job
    @company = @job.company
    @user = @job_application.user
    mail_to = @company.jobs_email
    mail_to = @job.email if @job.email.present?
    email_with_name = %(<#{ENV['MAIL_FROM']}>)
    mail(to: mail_to, subject: t('job_application.company_email.subject', :job => @job.name, :user => @user.name ),:reply_to => @user.email, :bcc => ENV['MAIL_FROM'])  do |format|
      format.html { render layout: 'mailer', template: 'job_application_mailer/company_email' }
      format.text { render template: 'job_application_mailer/company_email' }
    end
  end

  def company_without_bcc_email(job_application)
    @job_application = job_application
    @job = @job_application.job
    @company = @job.company
    @user = @job_application.user
    mail_to = @company.jobs_email
    mail_to = @job.email if @job.email.present?
    email_with_name = %(<#{ENV['MAIL_FROM']}>)
    mail(to: mail_to, subject: t('job_application.company_email.subject', :job => @job.name, :user => @user.name ),:reply_to => @user.email)  do |format|
      format.html { render layout: 'mailer', template: 'job_application_mailer/company_email' }
      format.text { render template: 'job_application_mailer/company_email' }
    end
  end

  def company_only_bcc_email(job_application)
    @job_application = job_application
    @job = @job_application.job
    @company = @job.company
    @user = @job_application.user
    mail_to = @company.jobs_email
    mail_to = @job.email if @job.email.present?
    email_with_name = %(<#{ENV['MAIL_FROM']}>)
    mail(subject: t('job_application.company_email.subject', :job => @job.name, :user => @user.name ),:reply_to => @user.email, :bcc => ENV['MAIL_FROM'])  do |format|
      format.html { render layout: 'mailer', template: 'job_application_mailer/company_email' }
      format.text { render template: 'job_application_mailer/company_email' }
    end
  end

  def user_email(job_application, event = nil)
    @job_application = job_application
    @job = @job_application.job
    @company = @job.company
    @event = event
    @user = @job_application.user
    email_with_name = %(<#{ENV['MAIL_FROM']}>)  
    mail(to: @user.email, subject: t('job_application.user_email.subject', :job => @job.name, :company => @company.name, :user => @user.name ))  do |format|
      format.html { render layout: 'mailer', template: 'job_application_mailer/user_email' }
      format.text { render template: 'job_application_mailer/user_email' }
    end
  end
end