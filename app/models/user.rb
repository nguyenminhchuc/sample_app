class User < ApplicationRecord
  before_save :email_downcase
  attr_reader :remember_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :name, presence: true,
            length: {maximum: Settings.validates_user.max_name}
  validates :email, presence: true,
            length: {maximum: Settings.validates_user.max_email},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :password, presence: true, length:
            {minimum: Settings.validates_user.min_password},
            allow_nil: true

  has_secure_password

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def forget
    update remember_digest: nil
  end

  def authenticated? remember_token
    return false unless remember_digest
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def current_user? user
    user == self
  end


  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end
  private

  def email_downcase
    email.downcase!
  end
end
