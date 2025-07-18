class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true

  has_many :posts, dependent: :destroy

  # Twitter OAuth attributes
  attribute :twitter_token, :string
  attribute :twitter_secret, :string
  attribute :twitter_uid, :string

  # LinkedIn OAuth attributes
  attribute :linkedin_uid, :string
  attribute :linkedin_token, :string
  attribute :linkedin_refresh_token, :string
  attribute :linkedin_expires_at, :datetime

  def twitter_connected?
    twitter_uid.present? && twitter_token.present? && twitter_secret.present?
  end

  def linkedin_connected?
    linkedin_uid.present? && linkedin_token.present?
  end

  def linkedin_token_valid?
    linkedin_token.present? && linkedin_expires_at.present? && linkedin_expires_at > Time.current
  end

  # Define a full name method for display
  def name
    "#{first_name} #{last_name}".strip
  end
end
