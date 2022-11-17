class Admin::CustomerSuccessPanelController < Admin::AdminController
  before_action :set_company, only: [:show]
  before_action -> { authorize [:admin, :customer_success_panel] }, only: :show

  def show
    @companies = Company.all.order(:name_id)
    @created = @company.created_at
    @company_views = @company.views
    @total_jobs = @company.jobs.count
    @total_applications = JobApplication.by_company(@company.id).count
    @thirty_days_to_end = @company.jobs.where(:end_date => Time.now..30.days.from_now)
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end
end
