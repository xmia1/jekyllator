class User < ActiveRecord::Base
  validates_presence_of :github_uid, :name
  validates_uniqueness_of :github_uid

  def self.from_omniauth(auth_hash)
    user = find_or_initialize_by(github_uid: auth_hash['uid'])
    user.name = auth_hash['info']['name']
    user.repo_url = auth_hash['extra']['raw_info']['repos_url']
    user.nickname = auth_hash['info']['nickname']
    #user.display
    #user.location = auth_hash['info']['location']
    #user.image_url = auth_hash['info']['image']
    #user.url = auth_hash['info']['urls']['Twitter']
    user.save!
    user
  end


end
