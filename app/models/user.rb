# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  api_token       :string
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_api_token      (api_token) UNIQUE
#  index_users_on_email_address  (email_address) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password_digest, presence: true

  def generate_api_token!
    update!(api_token: SecureRandom.hex(32))
  end

  def regenerate_api_token!
    generate_api_token!
  end
end
