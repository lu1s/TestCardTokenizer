require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
	test "creates and retreieves account through api" do
		puts 'testing correct account creation...'
		post :create_account, params: {name: 'unit_test_api_account'}
		assert_response :success
		json_response = JSON.parse(@response.body)
		assert json_response['success'], 'success should be true'
		assert json_response['data']['name'] == 'unit_test_api_account', 'name should have returned'
		assert json_response['data']['public_key'].size == 43, 'invalid public key length'
		assert json_response['data']['private_key'].size == 43, 'invalid private key length'
		public_key = json_response['data']['public_key']
		private_key = json_response['data']['private_key']

		puts 'testing correct account retreival...'
		post :get_account, params: {name: 'unit_test_api_account'}
		assert_response :success
		json_response = JSON.parse(@response.body)
		assert json_response['success'], 'success should be true'
		assert json_response['data']['public_key'].size == 43, 'invalid public key length'
		assert json_response['data']['private_key'].size == 43, 'invalid private key length'
		assert public_key == json_response['data']['public_key'], 'public key should be the same'
		assert private_key == json_response['data']['private_key'], 'private key should be the same'
		
		puts 'testing non-existing account retreival attempt...'
		post :get_account, params: {name: 'thisisafakename'}
		assert_response :missing
		json_response = JSON.parse(@response.body)
		assert json_response['success'] == false, 'success response should be false'
		assert json_response['message'] == 'Account not found', 'Incorrect message'
	end
end