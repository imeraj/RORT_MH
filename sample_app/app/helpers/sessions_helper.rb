require 'pusher'

module SessionsHelper
    @@pusher = Pusher::Client.new(
                app_id: Pusher.app_id,
                key: Pusher.key,
                secret: Pusher.secret,
                encrypted: true,
                authTransport: 'jsonp'
                )

    # log in current user
    def log_in(user)
        session[:user_id] = user.id

        @@pusher.trigger('presence-miniTwitter', 'user_logged_in', {
      		message: "#{current_user.name}"
    	})
    end

    # forget a persistent session
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # log out current user
    def log_out
        @@pusher.trigger('presence-miniTwitter', 'user_logged_out', {
            message: "#{current_user.name}"
        })
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end

    # returns the current logged-in user (if any)
    def current_user
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: user_id)
        elsif (user_id = cookies.signed[:user_id])
            user = User.find_by(id: user_id)
            if user && user.authenticated?(:remember, cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

	def current_user?(user)
		@user == current_user
	end

    def logged_in?
        !current_user.nil?
    end

    # remembers a user in a persistent session
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent.signed[:remember_token] = user.remember_token
    end

	# Redirects to stored location (or to the default)
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url)
	end

	# Stores the URL trying to be accessed
	def store_location
		session[:forwarding_url] = request.original_url if request.get?
	end

end
