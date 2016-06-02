class SuperAdmin < AdminUser
  def admin?
    true
  end
end