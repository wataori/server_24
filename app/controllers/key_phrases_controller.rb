class KeyPhrasesController < ApplicationController
  require 'twitter'
  # require "yahoo_keyphrase_api"
  require 'net/http'

  def index
    @users_favs = Favorite.where(user_id: current_user.id)
    @others_favs = Favorite.group(:user)
    render json: @others_favs
  end

  def show
  end

  def get_tweets
    @hoge = []

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = 'Q0mqOUL0P5OB0dsZ6FdJVUWVB'
      config.consumer_secret     = 'EAO1rMvkXMwTiZb3ms20l96FeDX71SE8GzMsguWsjRlqCVAeoR'
      config.access_token        = '519338540-yNAFQaEnCJ3D5Aq9dYg3aZI67FyHk6zucBCPaDB0'
      config.access_token_secret = 'XJCuo1eEHCNZf2ODNwO6SQnCctWd8vbCHNcI4TjaHbjzn'
    end

    client.user_timeline(screen_name: current_user.nickname, count: 200, exclude_replies: true, include_rts: false).each do |tweet|
      # Favorite.create(user_id: current_user.id, content: tweet.text, exclude_replies: true)
      @hoge.push(tweet.text)
    end

    # YahooKeyphraseApi::Config.app_id = "dj0zaiZpPThhYk8xaVFJSkJtUiZzPWNvbnN1bWVyc2VjcmV0Jng9MTc-"
    # ykp = YahooKeyphraseApi::KeyPhrase.new

    render json: @hoge
  end

  def word_search_result(target="")
    @return_text = ""
    @client.search(target, :result_type => "recent").take(200).each do |tweet|
        @return_text += tweet.text.gsub(target, "")
    end
    return @return_text
  end
end
