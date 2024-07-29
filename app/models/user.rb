class User < ApplicationRecord
  before_save :downcase_email

  validates :name, presence: true,
                   length: {maximum: Settings.degit.length_name.max}
  validates :email, presence: true,
                    length: {maximum: Settings.degit.length_email_max},
                    format: {with: Settings.regex.email},
                    uniqueness: true

  has_secure_password
  validates :password, presence: true,
                       length: {minimum: Settings.degit.length_password_min}

  private

  def downcase_email
    email.downcase!
  end
end
