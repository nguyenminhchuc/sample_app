class User < ApplicationRecord
  before_save :email_downcase

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :name, presence: true,
            length: {maximum: Settings.validates_user.max_name}
  validates :email, presence: true,
            length: {maximum: Settings.validates_user.max_email},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :password, presence: true, length:
            {minimum: Settings.validates_user.min_password}

  has_secure_password
  def email_downcase
    self.email = email.downcase
  end
end
