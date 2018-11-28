class User < ApplicationRecord
  has_many :active_relationships, class_name: "Relationship",
  foreign_key: "follower_id",
  dependent: :destroy
has_many :passive_relationships, class_name: "Relationship",
  foreign_key: "followed_id",
  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  NUMBER_REGEX = /\d[0-9]\)*\z/
  validates :name, presence: true, length: {maximum: 60}
  validates :email, presence: true, length: {maximum: 60},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: {case_sensitive: false}
  validates :password, presence: true,
    length: {minimum: 6}, allow_nil: true
  before_save {email.downcase!}
  has_many :comments
  has_many :entries
  has_many :relationships
  has_many :microposts, dependent: :destroy

  has_secure_password
  scope :show_user, ->  {select :id, :name, :email}

  class << self
    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password? token
  end

  def follow other_user
    following << other_user
  end

  def unfollow other_user
    following.delete other_user
  end

  def following? other_user
    following.include? other_user
  end

  def feed
    following_ids = Relationship.where(follower_id: id)
      .select(:followed_id).pluck :followed_id
    Micropost.where(Micropost.arel_table[:user_id].eq(id)
      .or(Micropost.arel_table[:user_id].in(following_ids)))
  end
end
