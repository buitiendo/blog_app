class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  scope :show_comment_desc, -> {order created_at: :desc}
end
