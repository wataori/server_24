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
    user = User.find(params[:id])

    render json: {
      id: user.id,
      icon: user.icon,
      name: user.nickname,
      content: Favorite.where(user_id: user.id).pluck(:content)
    }
  end
end
