class KeyPhrasesController < ApplicationController
  require 'twitter'
  require 'net/http'
  require 'open-uri'
  require 'json'

  def index
    @users_favs = Favorite.where(user_id: current_user.id)
    @others_favs = Favorite.group(:user)
    render json: @others_favs
  end

  def show
  end

  def get_tweets
    @hoge = []
    res = {}
    @aaaa = []

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = 'Q0mqOUL0P5OB0dsZ6FdJVUWVB'
      config.consumer_secret     = 'EAO1rMvkXMwTiZb3ms20l96FeDX71SE8GzMsguWsjRlqCVAeoR'
      config.access_token        = '519338540-yNAFQaEnCJ3D5Aq9dYg3aZI67FyHk6zucBCPaDB0'
      config.access_token_secret = 'XJCuo1eEHCNZf2ODNwO6SQnCctWd8vbCHNcI4TjaHbjzn'
    end

    client.user_timeline(screen_name: current_user.nickname, count: 200, exclude_replies: true, include_rts: false).each do |tweet|
      # Favorite.create(user_id: current_user.id, content: tweet.text, exclude_replies: true)

      @hoge.push(tweet.text)
      if @hoge.length === 30
        tweets = @hoge.join(' ')
        url = ERB::Util.url_encode(tweets)
        res = OpenURI.open_uri('http://jlp.yahooapis.jp/KeyphraseService/V1/extract?appid=dj0zaiZpPThhYk8xaVFJSkJtUiZzPWNvbnN1bWVyc2VjcmV0Jng9MTc-&output=json&sentence=' + url)
      end
    end
    @aaaa.push(JSON.load(res))

    @a = []
    @aaaa.each do |k, v|
      @a.push(k)
    end

    # YahooKeyphraseApi::Config.app_id = "dj0zaiZpPThhYk8xaVFJSkJtUiZzPWNvbnN1bWVyc2VjcmV0Jng9MTc-"
    # ykp = YahooKeyphraseApi::KeyPhrase.new

    render json: @aaaa
  end

  def http_request(method, uri, query_hash = {}, user = nil, pass = nil)
    uri = URI.parse(uri) if uri.is_a? String
    method = method.to_s.strip.downcase
    query_string = (query_hash||{}).map{|k,v|
      URI.encode(k.to_s) + "=" + URI.encode(v.to_s)
    }.join("&")

    if method == "post"
      args = [Net::HTTP::Post.new(uri.path), query_string]
    else
      args = [Net::HTTP::Get.new(uri.path + (query_string.empty? ? "" : "?#{query_string}"))]
    end
    args[0].basic_auth(user, pass) if user

    Net::HTTP.start(uri.host, uri.port) do |http|
      return http.request(*args)
    end
  end

  def word_search_result(target="")
    @return_text = ""
    @client.search(target, :result_type => "recent").take(200).each do |tweet|
        @return_text += tweet.text.gsub(target, "")
    end
    return @return_text
  end
end
