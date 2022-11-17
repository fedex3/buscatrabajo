class Admin::JobApplicationPolicy < Admin::ApplicationPolicy
	class Scope < Scope
    def resolve
      if user&.recruiter?
        scope.joins(:job).where("jobs.email = ?", user.email)
      elsif user&.company_role?
        scope.joins(:job).where("jobs.company_id = ?", user.company_id)
      else
        scope
      end
    end
  end

  def index?
    recruiter_action? || company_role_action?
  end

  def show?
    (recruiter_action? || company_role_action?)  && record_exists?
  end

	def accept?
    (recruiter_action? || company_role_action?)  && record_exists?
  end

  def reject?
    (recruiter_action? || company_role_action?)  && record_exists?
  end

	def positive_reject?
    (recruiter_action? || company_role_action?)  && record_exists?
  end

	def put_on_standby?
    (recruiter_action? || company_role_action?)  && record_exists?
  end

	def to_pending?
    (recruiter_action? || company_role_action?)  && record_exists?
  end

  def send_mail?
    recruiter_action? && record_exists?
  end
end
