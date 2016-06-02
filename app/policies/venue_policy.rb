class VenuePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
  #no access - no actions
  # def access
    # user.admin?
  # end
end
