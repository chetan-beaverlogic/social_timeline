class HomeController < ApplicationController
  def index
    if session[:gp_uid].present? && session[:gp_token].present?
     #render :text => session[:gp_token].inspect and return false
      GooglePlus.api_key  = GOOGLE_API_KEY
      person = GooglePlus::Person.get(session[:gp_uid], access_token: session[:gp_token])
      if person.present? && person.list_activities.present? && person.list_activities.items.present?
        @google_posts = person.list_activities.items
      end
    end

    if user_signed_in?
      #session.clear
      #fb_auth = current_user.facebook_auth
    else
      #session.clear
    end
    #render :text => session[:fb_token].inspect and return false
    if session[:fb_token].present?
      get_fb_graph_api_object(session[:fb_token])
      get_user_statues_details(session[:fb_uid])
      #render :text => @user_statuses_details["statuses"].inspect and return false
    end
    #tw_auth = current_user.twitter_auth
    if session[:tw_token].present? && session[:tw_secret].present?
      client  = Twitter::Client.new(oauth_token: session[:tw_token], oauth_token_secret: session[:tw_secret])
      @tweets = client.user_timeline(page: 1, count: 100)
    end

  end

  def get_user_statues_details(uid)
    @user_statuses_details = @graph.get_connections("#{uid}","?fields=statuses.limit(100000).fields(comments.limit(1000000),message,likes.limit(1000000))")
    @total_user_statuses_count = @user_statuses_details["statuses"].present? ? @user_statuses_details["statuses"]["data"].size : 0
  end

  def get_fb_graph_api_object(token)
    begin
      @graph = Koala::Facebook::API.new("#{token}")
    rescue Exception => e
      Rails.logger.info("=======================================> Error while initialise graph object: #{e.message} ")
    end
  end

  def back_to_root
    redirect_to root_path
  end

  def logout
    case params['provider']
      when 'twitter'
        session[:tw_token] = nil
        session[:tw_secret]= nil
      when 'facebook'
        token = session[:fb_token]
        session[:fb_token] = nil
        #redirect_to "https://www.facebook.com/logout.php?access_token=#{token}&redirect_uri=http://127.0.0.1:3000"
      when 'google_plus'
        session[:gp_uid] = nil
        session[:gp_token] = nil
    end
    redirect_to root_path

  end
end
