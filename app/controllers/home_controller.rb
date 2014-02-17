class HomeController < ApplicationController
  def index
    if user_signed_in?
      authentication = current_user.authentication
      if authentication.present?
        get_fb_graph_api_object(authentication.token)
        get_user_statues_details(authentication.uid)
        #render :text => @user_statuses_details["statuses"].inspect and return false
      end
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


end
