class CreditCardCollectionPolicy < ApplicationPolicy
	def approve?
    admin_action? && record_exists?
  end    
end
