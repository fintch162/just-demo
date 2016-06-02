class CustomFailure < Devise::FailureApp
  def redirect_url
    url = URI(request.referer).path
    if url.include?("/manage")
      flash[:login_failure] = "Login Failed."
      root_url 
    else
      # admin_dashboard_url
      flash[:login_failure] = "Login Failed."
      root_url 
    end
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end