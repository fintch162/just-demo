module ActiveAdmin
  class CommentPolicy < ::ApplicationPolicy
    class Scope < Struct.new(:user, :scope)
      def resolve
        scope
      end
    end
    def access
      user.admin?
    end
  end
end