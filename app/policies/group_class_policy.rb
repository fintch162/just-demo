class GroupClassPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.instructor?
        scope.where(instructor_id: user.id)
      else
        scope.all
      end
    end
  end
  # def access
    # user.admin?
  # end
end
