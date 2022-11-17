class Admin::Stats::CompaniesController < Admin::AdminController
  def index
    @job_applications = JobApplication.select("date_part('year', job_applications.created_at  AT TIME ZONE 'UTC' AT TIME ZONE 'ART') as year, date_part('month', job_applications.created_at  AT TIME ZONE 'UTC' AT TIME ZONE 'ART') as month, companies.name as company_name, count(job_applications.id) as total_job_applications").joins(:job => [:company]).group("date_part('year', job_applications.created_at  AT TIME ZONE 'UTC' AT TIME ZONE 'ART'), date_part('month', job_applications.created_at  AT TIME ZONE 'UTC' AT TIME ZONE 'ART'), companies.name").order("date_part('year', job_applications.created_at  AT TIME ZONE 'UTC' AT TIME ZONE 'ART') desc, date_part('month', job_applications.created_at  AT TIME ZONE 'UTC' AT TIME ZONE 'ART') desc, companies.name").page(params[:page])
  end
end


