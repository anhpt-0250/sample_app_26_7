class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  ATTRIBUTES_PERMITTED = %i(name email password password_confirmation).freeze

  before_save :downcase_email
  before_create :create_activation_digest

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

  def authenticated? attribute, token
    digest = public_send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end
  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
