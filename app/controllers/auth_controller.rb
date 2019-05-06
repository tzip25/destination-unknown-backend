class AuthController < ApplicationController
    def login
        # byebug
        user = User.find_by(username: params[:loginUsername])
    
    
        if user && user.authenticate(params[:loginPassword])
            token = encode_token(user.id)

            render json: {user: user, token: token}
        else
            render json: {errors: "You dun goofed!"}
        end
    end
    
    def auto_login
        if curr_user
            render json: curr_user
        else
            render json: {errors: "You dun goofed!"}
        end
    end
end