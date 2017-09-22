require 'twitter'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = '5b2JWEvSdfryi7r7CMFXLRonR'
  config.consumer_secret = 'WXqvUkHG83PMRtyCKJJJ29WyicK39qmqEqpAKUTuBmguc6qodf'
  config.access_token = '540187552-50M9hVJIRfysaCoeFOH41VGPZABMPHElMiynOzVf'
  config.access_token_secret = 'Pl976pBn8gYtaNvlGmrSO9C0tXjZLoXWoPvYFOwTotrjJ'
end

search_term = URI::encode('#HRTech')

SCHEDULER.every '10m', :first_in => 0 do |job|
  begin
    tweets = twitter.search("#{search_term}")

    if tweets
      tweets = tweets.map do |tweet|
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
      end
      send_event('twitter_mentions', comments: tweets)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end