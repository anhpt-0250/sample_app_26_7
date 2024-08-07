class Micropost < ApplicationRecord
  POSTS_PERMITTED = %i(content image).freeze

  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display,
                       resize_to_limit: [Settings.image_variant,
                                         Settings.image_variant]
  end
  delegate :name, to: :user, prefix: true
  scope :newest, ->{order created_at: :desc}
  scope :relate_post, ->(user_ids){where user_id: user_ids}

  validates :content, presence: true,
                      length: {maximum: Settings.degit.length_content_post}
  validates :image, content_type: {in: Settings.image_type,
                                   message: I18n.t("must_valid")},
                                   size: {less_than: Settings.image.megabytes,
                                          message: I18n.t("should_less")}
end
