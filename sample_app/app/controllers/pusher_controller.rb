require 'pusher'
require "json"
require "openssl"

class PusherController < ApplicationController
    before_action :authenticate

    def auth
        raise "Unknown channel" unless params[:channel_name] == 'presence-miniTwitter'

        if request.post?
            if current_user
                response = Pusher.authenticate(params[:channel_name], params[:socket_id], {
                    user_id: current_user.id, # => required
                    user_info: {
                        name: current_user.name,
                        email: current_user.email
                    }
                    })
                    render json: response
            else
                render text: 'Forbidden', status: '403'
            end
        end

        if request.get?
            json_user_data = JSON.generate({
                :user_id => current_user.id,
                :user_info => {:name => current_user.name, :email => current_user.email}
                })

            socket_id = params[:socket_id]
            secret = Pusher.secret
            channel_name = params[:channel_name]
            digest = OpenSSL::Digest::SHA256.new

            string_to_sign = "#{socket_id}:#{channel_name}:#{json_user_data}"
            signature = OpenSSL::HMAC.hexdigest(digest, secret, string_to_sign)

            response = {:auth => "#{Pusher.key}:#{signature}", :channel_data => "#{json_user_data}" }
            render json: response, :callback => params['callback']
        end
    end
end
