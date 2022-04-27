class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}

  validates :image, content_type: {in: %w[image/jpeg image/gif image/png], 
                      message: 'format should be: jpeg/gif/png'}, 
                    size: {less_than: 5.megabytes, 
                      message: "size must be less than 5 MB."}

  default_scope -> { order(created_at: :desc) }

  def display_image
    image.variant(resize_to_limit: [500, 500])
  end

end
