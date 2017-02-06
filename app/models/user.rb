class User < ActiveRecord::Base
  mount_uploader :avatar, ImageUploader
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :accounts, dependent: :destroy
  has_many :comments, dependent: :destroy

  validate :image_size_validation
  validates_integrity_of :avatar

  class << self
    def from_omniauth(auth)
      user = User.where(provider: auth.provider, uid: auth.uid).first ||
             User.find_by_email(auth.info.email)
      return user if user.present?

      User.create! do |u|
        u.provider      = auth.provider
        u.uid           = auth.uid
        u.oauth_token   = auth.credentials.token
        u.name          = auth.extra.raw_info.name
        u.remote_avatar = auth.info.image
        u.password      = Devise.friendly_token[0, 20]
        u.email         = auth.info.email || auth.uid + "@#{auth.provider}.com"
        provider        = auth.provider.capitalize 
        provider        = 'Google' if provider.include? 'Google'
        u.url           = auth.info.urls.send "#{provider}"
      end
    end # from_omniauth
  end # self

private
  def image_size_validation
    errors[:avatar] << "should be less than 5MB" if avatar.size > 5.megabytes
  end
end # User
