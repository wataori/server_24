class KeyPhrasesController < ApplicationController
  require 'twitter'

  def index
    @users_favs = Favorite.where(user_id: current_user.id)
    @others_favs = Favorite.group(:user)
    render json: @others_favs
  end

  def show
  end

  def get_tweets

    # @hoge = statuses_user_timeline

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = 'Q0mqOUL0P5OB0dsZ6FdJVUWVB'
      config.consumer_secret     = 'EAO1rMvkXMwTiZb3ms20l96FeDX71SE8GzMsguWsjRlqCVAeoR'
      config.access_token        = '519338540-yNAFQaEnCJ3D5Aq9dYg3aZI67FyHk6zucBCPaDB0'
      config.access_token_secret = 'XJCuo1eEHCNZf2ODNwO6SQnCctWd8vbCHNcI4TjaHbjzn'
    end
    @hoge = client.user(current_user.nickname)

    render json: @hoge
  end
end
