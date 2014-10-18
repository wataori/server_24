class SessionsController < ApplicationController
  require 'twitter'
  require 'net/http'
  require 'open-uri'
  require 'json'

  def callback
    auth = request.env['omniauth.auth']
    user = User.find_by(provider: auth['provider'], uid: auth['uid']) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    redirect_to loged_in_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  def loged_in
    res = {}

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = 'Q0mqOUL0P5OB0dsZ6FdJVUWVB'
      config.consumer_secret     = 'EAO1rMvkXMwTiZb3ms20l96FeDX71SE8GzMsguWsjRlqCVAeoR'
      config.access_token        = '519338540-yNAFQaEnCJ3D5Aq9dYg3aZI67FyHk6zucBCPaDB0'
      config.access_token_secret = 'XJCuo1eEHCNZf2ODNwO6SQnCctWd8vbCHNcI4TjaHbjzn'
    end

    tweets = client.user_timeline(screen_name: current_user.nickname, count: 200, exclude_replies: true, include_rts: false)

    offset = 0

    while tweets[offset...(offset + 5)].present? do
      partial_tweets = tweets[offset...(offset + 5)]
      threshold = [5, partial_tweets.length].min

      hoge = []
      partial_tweets.each do |tweet|
        hoge.push(tweet.text)
        if hoge.length === threshold
          tweets_str = hoge.join(' ')
          url = ERB::Util.url_encode(tweets_str)
          res = OpenURI.open_uri('http://jlp.yahooapis.jp/KeyphraseService/V1/extract?appid=dj0zaiZpPThhYk8xaVFJSkJtUiZzPWNvbnN1bWVyc2VjcmV0Jng9MTc-&output=json&sentence=' + url)
        end
      end

      aaaa = JSON.load(res)

      if aaaa.present?
        words = aaaa.keys # 単語が入った配列を取得
        words.each do |word| # 単語の情報を保存
          Favorite.create(
            content: word,
            user_id: current_user.id
          )
        end
      end
      offset += 5
    end

    render json: {
      id: current_user.id
    }
  end
end
