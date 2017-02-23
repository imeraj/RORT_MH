require 'elasticsearch/model'

class Micropost < ApplicationRecord
	include Elasticsearch::Model
  	include Elasticsearch::Model::Callbacks

	belongs_to :user
	default_scope -> { order(created_at: :desc) }
	mount_uploader :picture, PictureUploader
	validates :user_id, presence: true
	validates :content, presence: true, length: { maximum: 140 }
	validate  :picture_size

	def as_indexed_json(options={})
    	as_json(
        	include: {user: {except: [:password_digest, :activation_digest, :remember_digest]}}
			)
	end

	# Validates the size of an uploaded picture.
	 def picture_size
		 if picture.size > 5.megabytes
			 errors.add(:picture, "should be less than 5MB")
		 end
	 end

	 def self.search(query)
	   __elasticsearch__.search(
	     {
	       query: {
	         multi_match: {
	           query: query,
	           fields: ['content']
	         }
	       },
	       highlight: {
	         pre_tags: ['<em>'],
	         post_tags: ['</em>'],
	         fields: {
	           content: {}
	         }
	       }
	     }
	   )
	 end
end
