class ChargesController < ApplicationController
	def create_charge
		if params[:card_token].nil? or params[:amount].nil? or params[:account_name].nil?
			error_response 400, "Missing parameters"
			return
		end
		if params[:amount].to_d < 0.01 or params[:amount] !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
			error_response 400, "Amount must be decimal greater or equal than 0.01"
			return
		end
		if !Account.where(name: params[:account_name]).present?
			error_response 404, "Account to deposit was not found"
			return
		end
		card = Card.where(card_token: params[:card_token]).first
		if card.nil? or (card.token_timestamp + 10.minute).past?
			error_response 401, "Invalid or expired token"
			return
		end
		account = Account.where(name: params[:account_name]).first
		charge = Charge.create(account: account, 
							card: card, 
							amount: params[:amount].to_d,
							charge_timestamp: DateTime.now)
		success_response "OK"
	end
end
