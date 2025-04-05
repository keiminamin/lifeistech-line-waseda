require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection
class Chat < ActiveRecord::Base
  # 必要に応じてバリデーションなどを追加できます
  # validates :cloudinary_public_id, presence: true
  # validates :url, presence: true
end