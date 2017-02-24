require 'pusher'

class RelationshipsController < ApplicationController
	before_action :authenticate

	def create
		user = User.find(params[:followed_id])
		current_user.follow(user)
		Pusher.trigger("miniTwitter-#{user.name}-channel", "miniTwitter-event", {
      		message: "#{current_user.name} is following you!"
    	})
		redirect_to user
	end

	def destroy
		user = Relationship.find(params[:id]).following
		current_user.unfollow(user)
		redirect_to user
	end

end
