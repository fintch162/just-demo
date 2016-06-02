class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    access
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def new?
    create?
  end

  def create?
    access
  end

  def edit?
    update?
  end

  def update?
    access
  end

  def destroy?
    access
  end

  def destroy_all?
    access
  end

  def access
    true
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end
end
