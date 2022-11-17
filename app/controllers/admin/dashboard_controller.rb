class Admin::DashboardController < Admin::AdminController
  #before_action -> { authorize [:admin, :dashboard] }, only: :index

  def index
    if current_user.company_role? && current_user.company_id.present?
      @listable_jobs_by_company = Job.where(company_id: current_user.company_id).listable
      @job_applications_of_listable_jobs_by_company = JobApplication.by_company(current_user.company_id).job(@listable_jobs_by_company)
      @listable_jobs_views_by_company = Job.select(:views).where(company_id: current_user.company_id).listable.sum(:views)

      @offices = Company.find(current_user.company_id).offices
      @available_credits_for_tests = Company.find_by(id: current_user.company_id).available_credits_for_tests
    elsif current_user.admin? || current_user.superadmin? || current_user.recruiter?
      @listable_jobs = Job.listable
      @job_applications_of_listable_jobs = JobApplication.job(@listable_jobs)
      @listable_jobs_views = Job.select(:views).listable.sum(:views)
    end
  end

  def get_company_offices_completeness(offices)
    total_items = offices.count * 4
    items_completed = 0

    offices.each do |office|
      items_completed += 1 if office.has_five_active_photos?
      items_completed += 1 if office.has_one_active_video?
      items_completed += 1 if office.has_three_speeches?
      items_completed += 1 if office.has_four_stories?
    end

    (items_completed * 100) / total_items
  end
end
