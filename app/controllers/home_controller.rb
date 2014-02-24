class HomeController < ApplicationController
  def index
    @current_selected_user = current_user
    if @current_selected_user.present?

      fetch_google_plus_timeline(@current_selected_user)
      fetch_facebook_timeline(@current_selected_user)
      fetch_twitter_timeline(@current_selected_user)
    end

  end


  def fetch_twitter_timeline(current_selected_user)
    begin
      if current_selected_user and current_selected_user.twitter_auth.present?
        if !current_selected_user.twitter_auth.time_line_statuses.present?
          client = Twitter::Client.new(oauth_token: current_selected_user.twitter_auth.token, oauth_token_secret: current_selected_user.twitter_auth.secret)
          @tweets = client.user_timeline(page: 1, count: 100)
          if @tweets.present?
            @tweets.each do |tweet|
              TimeLineStatus.create(status: tweet.text, authentication_id: current_selected_user.twitter_auth.id)
            end
          end
        end
      end
    rescue Exception => e
      puts "========== Error: #{e.message}"
    end
  end

  def fetch_facebook_timeline(current_selected_user)
    begin
      if current_selected_user and current_selected_user.facebook_auth.present?
        get_fb_graph_api_object(current_selected_user.facebook_auth.token)
        get_user_statues_details(current_selected_user.facebook_auth.uid, current_selected_user)
      end
    rescue Exception => e
      puts "===========Error #{e.message}"
    end
  end

  def fetch_google_plus_timeline(current_selected_user)
    begin
      if current_selected_user and current_selected_user.google_plus_auth.present?
        if !current_selected_user.google_plus_auth.time_line_statuses.present?
          person = GooglePlus::Person.get(current_selected_user.google_plus_auth.uid)
          if person.present? && person.list_activities.present? && person.list_activities.items.present?
            @google_posts = person.list_activities.items
          end
          if @google_posts.present?
            GooglePlus.api_key = GOOGLE_API_KEY
            @google_posts.each do |post|
              TimeLineStatus.create(status: post.title, authentication_id: current_selected_user.google_plus_auth.id)
            end
          end
        end
      end

    rescue Exception => e
      puts "============= ERROR: #{e.message}"
    end
  end

  def get_user_statues_details(uid,current_selected_user)
    if !current_selected_user.facebook_auth.time_line_statuses.present?
      @user_statuses_details = @graph.get_connections("#{uid}","?fields=statuses.limit(100000).fields(comments.limit(1000000),message,likes.limit(1000000))")
      @total_user_statuses_count = @user_statuses_details["statuses"].present? ? @user_statuses_details["statuses"]["data"].size : 0
      if @user_statuses_details["statuses"] && @user_statuses_details["statuses"]['data'].present?
        @user_statuses_details["statuses"]['data'].each do |status|
          if status['message'].present?
            TimeLineStatus.create(status: status['message'] ,authentication_id: current_selected_user.facebook_auth.id)
          end
        end
      end
    end
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
        twitter_auth  = current_user.twitter_auth
        twitter_auth.destroy
        redirect_to root_path
      when 'facebook'
       # render :text => current_user.facebook_auth.inspect and return false
        fb_auth  = current_user.facebook_auth
        token = fb_auth.token
        fb_auth.destroy
        redirect_to "https://www.facebook.com/logout.php?access_token=#{token}&next=http://127.0.0.1:3000"
      when 'google_plus'
        google_auth  = current_user.google_plus_auth
        google_auth.destroy
        redirect_to root_path

    end

  end

  def public_time_line
    @current_selected_user = User.find(params[:id])
    if @current_selected_user.present?
      fetch_google_plus_timeline(@current_selected_user)
      fetch_facebook_timeline(@current_selected_user)
      fetch_twitter_timeline(@current_selected_user)
    end

  end

  def time_line_status_params
    params.require(:time_line_status).permit!
  end

end
