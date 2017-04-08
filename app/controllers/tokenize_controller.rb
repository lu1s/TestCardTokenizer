class TokenizeController < ApplicationController
	def tokenize
		required_params = [
			:card_number,
			:expiration_month,
			:expiration_year,
			:secure_code
		]
		required_params.each do |x|
			if params[x].nil?
				error_response 400, "Missing parameters"
				return
			end
		end
		if !Card.valid?(params[:card_number])
			error_response 406, "Invalid card number"
			return
		end
		if params[:expiration_month].to_i < 1 or params[:expiration_month].to_i > 12
			error_response 406, "Invalid expiration month"
			return
		end
		if params[:expiration_year].to_i < Date.today.year or params[:expiration_year].to_i > (Date.today + 100.year).year
			error_response 406, "Invalid expiration year"
			return
		end
		if Date.new(params[:expiration_year].to_i, params[:expiration_month].to_i, 01) < Date.today
			error_response 406, "Card already expired"
			return
		end
		c = Card.secure_create_or_update(params[:card_number], 
			params[:expiration_year],
			params[:expiration_month],
			params[:secure_code])
		success_response "OK", {token: c.card_token, expires: (DateTime.now + 10.minute).to_s}
	end
end
