class Admin::DashboardController < Admin::AdminController
  #before_action -> { authorize [:admin, :dashboard] }, only: :index

  def index
    @listable_jobs = Job.listable
    @job_applications_of_listable_jobs = JobApplication.job(@listable_jobs)
    @listable_jobs_views = Job.select(:views).listable.sum(:views)
  end

  def get_company_offices_completeness(offices)
    total_items = offices.count * 4
    items_completed = 0

    offices.each do |office|
      items_completed += 1 if office.has_five_active_photos?
      items_completed += 1 if office.has_one_active_video?
      items_completed += 1 if office.has_three_speeches?
    end

    (items_completed * 100) / total_items
  end
end
