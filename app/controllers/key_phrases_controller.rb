class KeyPhrasesController < ApplicationController
  require 'twitter'
  require 'net/http'
  require 'open-uri'
  require 'json'

  def index
    user_id = params[:user_id].present? ? params[:user_id].to_i : current_user.id
    c_user = User.find(user_id)

    users = User.where(room: c_user.room).where.not(id: c_user.id)
    json = []
    levels = {}

    favorites = Favorite.where(user_id: users.pluck(:id))
    my_favorites = Favorite.where(user_id: user_id).pluck(:content)

    raw_level_data = ActiveRecord::Base.connection.execute('SELECT user_id, count(*) as c FROM favorites WHERE content IN (SELECT content FROM favorites WHERE user_id = ' + user_id.to_s + ') GROUP BY user_id;')

    raw_level_data.each do |record|
      levels[record['user_id'].to_s] = record['c']
    end

    users.each do |user_info|
      user = {
        id: user_info.id,
        icon: user_info.icon,
        name: user_info.nickname,
        level: levels[user_info.id.to_s] || 0,
        content: favorites.where(user_id: user_info.id).pluck(:content) & my_favorites
      }
      json.push(user)
    end

    render json: json
  end

  def show
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
