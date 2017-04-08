class AccountsController < ApplicationController
	def get_account
		if params[:name].nil?
			error_response 400, "No name defined"
			return
		end
		account = Account.where(name: params[:name]).first
		if account.nil?
			error_response 404, "Account not found"
			return
		end
		success_response "OK", {public_key: account.public_key, private_key: account.private_key}
	end
	def create_account
		if params[:name].nil?
			error_response 400, "Name was not present"
			return
		end
		if Account.where(name: params[:name]).present?
			error_response 409, "Another account with same name already exists"
			return
		end
		account = Account.generate(params[:name])
		success_response "OK", account
	end
	def list_charges
		account = Account.where(name: params[:name]).first
		if account.nil?
			error_response 404, "Account not found"
		end
		charges = Charge.where(account_id: account.id).order(charge_timestamp: :desc)
		success_response "OK", {charges: charges}
	end
end
