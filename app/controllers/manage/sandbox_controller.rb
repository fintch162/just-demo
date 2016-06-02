class Manage::SandboxController < Manage::BaseController
	include ApplicationHelper
  before_action :user_manage_permission
  def sandbox
  end
end