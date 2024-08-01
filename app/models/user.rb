class User < ApplicationRecord
  attr_accessor :remember_token

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
                       length: {minimum: Settings.degit.length_password_min},
                       allow_nil: true

  scope :ordered_by_name, ->{order(name: :asc)}

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def forget
    update_column :remember_digest, nil
  end

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end
  private

  def downcase_email
    email.downcase!
  end
end
