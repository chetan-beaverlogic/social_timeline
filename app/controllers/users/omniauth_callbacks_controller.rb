class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    if current_user.present?
      auth  = current_user.facebook_auth
      if auth.present?
        update_authentication('facebook')
      else
        create_authentication('facebook')
      end
    else
      redirect_to new_user_session_path
    end
    redirect_to root_path
  end

  def twitter
    if current_user.present?
      auth  = current_user.twitter_auth
      if auth.present?
        update_authentication('twitter')
      else
        create_authentication('twitter')
      end
    else
      redirect_to new_user_session_path
    end
    redirect_to root_path
  end


  def update_authentication(provider)
    case provider
      when 'facebook'
        authentication = current_user.facebook_auth
        authentication.update_attribute('token', request.env["omniauth.auth"].credentials.token)
      when 'twitter'
        authentication = current_user.twitter_auth
        authentication.update_attributes({'token' =>  request.env["omniauth.auth"].credentials.token, 'secret' => request.env["omniauth.auth"].credentials.secret})
    end
  end

  private

  def create_authentication(provider)
    auth = Authentication.new
    auth.uid = request.env["omniauth.auth"].uid
    auth.token = request.env["omniauth.auth"].credentials.token
    if provider == 'twitter'
      auth.secret = request.env["omniauth.auth"].credentials.secret
    end
    auth.provider = provider
    auth.user_id = current_user.id
    auth.save
  end

end
