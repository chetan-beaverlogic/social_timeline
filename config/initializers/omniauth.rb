module OmniAuth::Strategies

  #Reference - http://cookieshq.co.uk/posts/how-to-create-multiple-facebook-omniauth-strategies-for-the-same-application/
    class GooglePlus < GoogleOauth2
    def name
      :google_plus
    end
  end

end