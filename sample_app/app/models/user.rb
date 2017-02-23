class User < ApplicationRecord
	include Elasticsearch::Model
	include Elasticsearch::Model::Callbacks

	has_many :microposts, dependent: :destroy
	has_many :active_relationships,  class_name: "Relationship",
									 foreign_key: "follower_id",
									 dependent: :destroy
	has_many :passive_relationships, class_name:  "Relationship",
									 foreign_key: "following_id",
									 dependent: :destroy

	has_many :following, through: :active_relationships,  source: :following
	has_many :followers,  through: :passive_relationships, source: :follower

	attr_accessor :remember_token, :activation_token, :reset_token
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	before_create :create_activation_digest
	before_save   :downcase_email

    validates :name,  presence: true, length: { maximum:  50 }
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: true }

    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }, allow_blank: true


    # remembers a user in the database for use in persistent sessions
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(self.remember_token))
    end

    # returns true if the given token matches the digest
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
		return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # forgets a user
    def forget
        update_attribute(:remember_digest, nil)
    end

	# activates an account
	def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end

	# Sends activation email
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest, User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
	end

	def password_reset_expired?
		self.reset_sent_at < 2.hours.ago
	end

	def feed
		 Micropost.where("user_id = ? OR user_id IN(?)", id, User.find(id).following_ids)
	end

	# follow a user
	def follow(other_user)
		following << other_user
	end

	# unfollow a user
	def unfollow(other_user)
		following.delete(other_user)
	end

	def following?(other_user)
		following.include?(other_user)
	end

    class << self
        # returns the hash digest of the given string
        def digest(string)
            cost  = ActiveModel::SecurePassword::min_cost ? BCrypt::Engine::MIN_COST:
                                                            BCrypt::Engine.cost
            BCrypt::Password.create(string, cost: cost)
        end

        # returns a random token
        def new_token
            SecureRandom.urlsafe_base64
        end
    end

	private
	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(self.activation_token)
	end

	def downcase_email
		self.email = email.downcase
	end
end
