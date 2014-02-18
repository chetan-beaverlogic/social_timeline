class HomeController < ApplicationController
  def index
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
    unless session[:fb_token].present?
      redirect_to "https://www.facebook.com/logout.php?access_token=#{session[:fb_token]}&next=http://social-timeline.herokuapp.com/"
      session.clear
    else
      session.clear
      redirect_to root_path
    end
  end
end
