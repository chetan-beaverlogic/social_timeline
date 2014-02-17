class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    data = request.env["omniauth.auth"].extra.raw_info
    session[:access_token] = request.env["omniauth.auth"].credentials.token
    if data.email.nil?
      @email = data.link
    else
      @email = data.email
    end
    user = User.find_by_email(@email)
    if user.present?
      user
      update_authentication(user)
    else # Create a user with a stub password.
      user = create_new_user()
      create_authentication(data, user)
    end

    if user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "#{params[:action]}".capitalize
      sign_in_and_redirect user, :event => :authentication
    else
      session["devise.#{params[:action]}_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def create_new_user
    user = User.new
    user.email = @email
    user.encrypted_password = Devise.friendly_token[0, 20]
    user.save(:validate => false)
    user
  end

  def update_authentication(user)
    authentication = Authentication.find_by_user_id(user.id)
    if authentication.present?
      authentication.update_attribute('token', request.env["omniauth.auth"].credentials.token)
    else
      create_authentication(request.env["omniauth.auth"],user)
    end
  end

  private

  def create_authentication(data, user)
    auth = Authentication.find_by_uid_and_user_id(data.uid, @email)
    if auth.nil?
      authentication = Authentication.new
      authentication.uid = request.env["omniauth.auth"].uid
      authentication.token = request.env["omniauth.auth"].credentials.token
      authentication.user_id = user.id
      authentication.save
    end
  end

end
