class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # def initialize(token, secret)
  #   @twitter_client = self.make_twitter_client(token, secret)
  # end 

  def make_twitter_client(token, secret)
    Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_api_key      # "YOUR_CONSUMER_KEY"
      config.consumer_secret     = Rails.application.secrets.twitter_api_secret   # "YOUR_CONSUMER_SECRET"
      config.access_token        = token                                          # "YOUR_ACCESS_TOKEN"
      config.access_token_secret = secret                                         # "YOUR_ACCESS_SECRET"
    end
  end 

  def get_tweets_from(screen_name)
    @twitter_client.user_timeline(:screen_name => screen_name, :count => 179)
    
    # last_id = timeline.last.id - 1 
    # 4.times do 
    #   sleep(1)
    #   timeline = timeline + @twitter_client.user_timeline(:screen_name => screen_name, :count => 179, :max_id => last_id)
    #   last_id = timeline.last.id - 1
    # end 

  end

  def extract_text_from_tweets(tweet_array)
    string_array = []
    tweet_array.each do |tweet_obj|
      string_array << tweet_obj.text
    end

    string_array
  end 


  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.username = auth.info.nickname
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

end
