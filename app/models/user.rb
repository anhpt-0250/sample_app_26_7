class User < ApplicationRecord
  ATTRIBUTES_PERMITTED = %i(name email password password_confirmation).freeze

  before_save :downcase_email

  validates :name, presence: true,
                   length: {maximum: Settings.degit.length_name_max}
  validates :email, presence: true,
                    length: {maximum: Settings.degit.length_email_max},
                    format: {with: Settings.regex.email},
                    uniqueness: true

  has_secure_password
  validates :password, presence: true,
                       length: {minimum: Settings.degit.length_password_min}

  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create string, cost
  end
  private

  def downcase_email
    email.downcase!
  end
end
