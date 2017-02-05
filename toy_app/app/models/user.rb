class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    validates :name, :email, presence: true
end
