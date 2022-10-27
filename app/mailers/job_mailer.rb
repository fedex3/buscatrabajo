class JobMailer < ApplicationMailer
    def job_ending_in_72hs(job)
        @job = job
        @company = @job.company
        mail_to = @company.jobs_email
        mail_to = @job.email if @job.email.present?
        email_with_name = %(<#{ENV['MAIL_FROM']}>)
        mail(to: mail_to, subject: t('job.mailer.subject', job:@job.name), :bcc => ENV['MAIL_FROM'])  do |format|
          format.html { render layout: 'mailer', template: 'job_mailer/job_ending_in_72hs_email' }
          format.text { render template: 'job_mailer/job_ending_in_72hs_email' }
        end
    end
end
