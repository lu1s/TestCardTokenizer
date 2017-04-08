require 'test_helper'

class ChargesControllerTest < ActionController::TestCase
	test "correctly creates a charge or fails if errors" do

		stashed_controller = @controller

		@controller = TokenizeController.new

		puts 'testing valid charge...'
		post :tokenize, params: {
			card_number: CreditCardValidations::Factory.random(:visa),
			expiration_month: (DateTime.now + 1.month).month.to_s,
			expiration_year: (DateTime.now + 1.year).year.to_s,
			secure_code: rand(101..405).to_s
		}
		assert_response :success
		json_response = JSON.parse(@response.body)
		assert json_response["success"], "not success response"
		assert json_response['message'] == "OK", "incorrect response msg"
		assert json_response['data']['token'].size == 43, 'incorrect token length'
		assert json_response['data']['expires'].to_datetime < (DateTime.now + 11.minute), 'too high expiration time'

		token = json_response["data"]["token"]

		@controller = AccountsController.new

		post :create_account, params: {name: 'unit_test_api_account'}
		assert_response :success
		json_response = JSON.parse(@response.body)
		assert json_response['success'], 'success should be true'
		assert json_response['data']['name'] == 'unit_test_api_account', 'name should have returned'
		assert json_response['data']['public_key'].size == 43, 'invalid public key length'
		assert json_response['data']['private_key'].size == 43, 'invalid private key length'

		@controller = stashed_controller

		post :create_charge, params: {
			card_token: token,
			amount: rand(45.5..250.5).to_s,
			account_name: 'unit_test_api_account'
		}
		assert_response :success
		json_response = JSON.parse(@response.body)
		assert json_response["success"], "success should be true"
		assert json_response["message"] == "OK", "OK message should have been thrown"

		#check for some failed charge attempts
		puts 'testing incorrect token...'
		post :create_charge, params: {
			card_token: "incorrecttoken",
			amount: rand(45.5..250.5).to_s,
			account_name: 'unit_test_api_account'
		}
		assert_response 401
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "success should be false"
		assert json_response["message"] == "Invalid or expired token", "invalid token msg is incorrect"

		puts 'testing missing params...'
		post :create_charge, params: {
			card_token: token,
			account_name: 'unit_test_api_account'
		}
		assert_response 400
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "success should be false"
		assert json_response["message"] == "Missing parameters"

		puts 'testing invalid amount...'
		post :create_charge, params: {
			card_token: token,
			amount: (-24).to_s,
			account_name: 'unit_test_api_account'
		}
		assert_response 400
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "success should be false"
		assert json_response["message"] == "Amount must be decimal greater or equal than 0.01"

		puts 'testing non existing account on a charge...'
		post :create_charge, params: {
			card_token: token,
			amount: rand(45.5..250.5).to_s,
			account_name: 'notgoingtobefoundaccount'
		}
		assert_response 404
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "success should be false"
		assert json_response["message"] == "Account to deposit was not found"

		#hijack our tokenized card to expire the token
		card = Card.where(card_token: token).first
		card.update_attributes(token_timestamp: (DateTime.now - 30.minute))

		puts 'testing charge attempt with expired token...'
		post :create_charge, params: {
			card_token: token,
			amount: rand(45.5..250.5).to_s,
			account_name: 'unit_test_api_account'
		}
		assert_response 401
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "success should be false"
		assert json_response["message"] == "Invalid or expired token", "token expiration error must be there"
	end
end