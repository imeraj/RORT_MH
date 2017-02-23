class SearchController < ApplicationController
    before_action :authenticate

    def search
        @user = current_user
        if params[:term].nil?
            @microposts = []
        else
            @microposts = Micropost.search params[:term]
        end
    end
end
