class User < ActiveRecord::Base
  has_many :favorites
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.nickname = auth['info']['nickname']
      user.name = auth['info']['name']
      user.icon = auth['info']['image']
    end
  end
end
