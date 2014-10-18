class KeyPhrasesController < ApplicationController
  require 'twitter'
  require 'net/http'
  require 'open-uri'
  require 'json'

  def index
    users_favs = Favorite.where(user_id: current_user.id).pluck(:content)
    users = User.where(room: current_user.room).where.not(id: current_user.id)
    json = []

    users.each do |user|
      other_favs = Favorite.where(user_id: user.id).pluck(:content)
      user = {
        id: user.id,
        icon: user.icon,
        name: user.nickname,
        content: other_favs
      }
      json.push(user)
    end

    render json: json
  end

  def show
    user = User.find(params[:id])

    render json: {
      id: user.id,
      icon: user.icon,
      name: user.nickname,
      content: Favorite.where(user_id: user.id).pluck(:content)
    }
  end

  def get_tweets
    @hoge = []
    res = {}

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = 'Q0mqOUL0P5OB0dsZ6FdJVUWVB'
      config.consumer_secret     = 'EAO1rMvkXMwTiZb3ms20l96FeDX71SE8GzMsguWsjRlqCVAeoR'
      config.access_token        = '519338540-yNAFQaEnCJ3D5Aq9dYg3aZI67FyHk6zucBCPaDB0'
      config.access_token_secret = 'XJCuo1eEHCNZf2ODNwO6SQnCctWd8vbCHNcI4TjaHbjzn'
    end

    client.user_timeline(screen_name: current_user.nickname, count: 200, exclude_replies: true, include_rts: false).each do |tweet|

      @hoge.push(tweet.text)
      if @hoge.length === 20
        tweets = @hoge.join(' ')
        url = ERB::Util.url_encode(tweets)
        res = OpenURI.open_uri('http://jlp.yahooapis.jp/KeyphraseService/V1/extract?appid=dj0zaiZpPThhYk8xaVFJSkJtUiZzPWNvbnN1bWVyc2VjcmV0Jng9MTc-&output=json&sentence=' + url)
      end
    end
    aaaa = JSON.load(res)

    words = aaaa.keys # 単語が入った配列を取得

    words.each do |word| # 単語の情報を保存
      Favorite.create(
        content: word,
        user_id: current_user.id
      )
    end

    render json: aaaa
  end
end
