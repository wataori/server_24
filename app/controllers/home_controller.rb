class HomeController < ApplicationController
  def index
  end

  def me
    user = User.find(current_user.id)

    render json: {
      icon: user.icon,
      name: user.nickname,
      content: Favorite.where(user_id: current_user.id).pluck(:content)
    }
  end
end
