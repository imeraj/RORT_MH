class MicropostsController < ApplicationController
	before_action :authenticate, :only => ["create", "destroy"]
	before_action :correct_owner,   only: :destroy

	def create
		@micropost = current_user.microposts.build(micropost_params)
        if @micropost.save
        	flash[:success] = "Micropost created!"
			redirect_to current_user
	 	else
			@feed_items = []
        	render 'static_pages/home'
       	end
	end

	def destroy
		@micropost.destroy
		flash[:success] = "Micropost deleted"
		redirect_to request.referrer || root_url
	end

	private
    def micropost_params
		params.require(:micropost).permit(:content, :picture)
	end

	def correct_owner
		@micropost = current_user.microposts.find_by(id: params[:id])
		redirect_to root_url if @micropost.nil?
	end
end
