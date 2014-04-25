class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def initialize(token, secret)
    @twitter_client = self.make_twitter_client(token, secret)
    @tweets = []
  end 

  def make_twitter_client(token, secret)
    Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_api_key      # "YOUR_CONSUMER_KEY"
      config.consumer_secret     = Rails.application.secrets.twitter_api_secret   # "YOUR_CONSUMER_SECRET"
      config.access_token        = token                                          # "YOUR_ACCESS_TOKEN"
      config.access_token_secret = secret                                         # "YOUR_ACCESS_SECRET"
    end
  end 

  def make_tweets
    timeline = []

    timeline = @twitter_client.home_timeline(:count => 199)
    last_id = timeline.last.id - 1 

    4.times do 
      sleep(1)
      timeline = timeline + @twitter_client.home_timeline(:count => 199, :max_id => last_id)
      last_id = timeline.last.id - 1
    end 

    timeline.each do |tweet_obj|
      @tweets << Tweet.new(tweet_obj)
    end
  end


end
