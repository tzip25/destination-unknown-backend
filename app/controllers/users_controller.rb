class UsersController < ApplicationController

    def create
        # byebug
        user = User.new(
			name: params[:signupName],
			username: params[:signupUsername],
			password: params[:signupPassword],
		)

		if user.save
			token = encode_token(user.id)

            render json: {user: user, token: token}
		else
			render json: {errors: user.errors.full_messages}
		end
    end
end
