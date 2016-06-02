class OnlinePaymentPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
  def access
    !user.instructor?  #the same as user.admin? || user.coordinator?
  end
end
