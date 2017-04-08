require 'test_helper'

class TokenizeControllerTest < ActionController::TestCase
	test "correctly tokenizes cards" do
		puts 'testing correct tokenization...'
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
	end
	test "correctly rejects invalid requests" do
		puts 'testing missing parameters...'
		post :tokenize, params: {
			expiration_month: "4"
		}
		assert_response 400
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "incorrect success response"
		assert json_response["message"] == "Missing parameters", "there should have been missing parameters"

		puts 'testing invalid card tokenization attempt...'
		post :tokenize, params: {
			card_number: "1946325075896322",
			expiration_month: "8",
			expiration_year: (DateTime.now + 1.year).year.to_s,
			secure_code: rand(101..405).to_s
		}
		assert_response 406
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "incorrect success response"
		assert json_response["message"] == "Invalid card number", "card number should have been invalid"

		puts 'testing invalid expiration month tokenization attempt...'
		post :tokenize, params: {
			card_number: CreditCardValidations::Factory.random(:mastercard),
			expiration_month: "25",
			expiration_year: (DateTime.now + 1.year).year.to_s,
			secure_code: rand(101..405).to_s
		}
		assert_response 406
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "incorrect success response"
		assert json_response["message"] == "Invalid expiration month", "expiration month should have been invalid"

		puts 'testing invalid expiration year tokenization attempt...'
		post :tokenize, params: {
			card_number: CreditCardValidations::Factory.random(:maestro),
			expiration_month: "3",
			expiration_year: (DateTime.now - 2.year).year.to_s,
			secure_code: rand(101..405).to_s
		}
		assert_response 406
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "incorrect success response"
		assert json_response["message"] == "Invalid expiration year", "expiration year should be invalid"

		old_date = DateTime.now - 2.month
		puts 'testing expired card tokenization attempt...'
		post :tokenize, params: {
			card_number: CreditCardValidations::Factory.random(:amex),
			expiration_month: old_date.month.to_s,
			expiration_year: old_date.year.to_s,
			secure_code: rand(101..405)
		}
		assert_response 406
		json_response = JSON.parse(@response.body)
		assert json_response["success"] == false, "incorrect success response"
		assert json_response["message"] == "Card already expired", "card expired message should have beem thrown"
	end
end