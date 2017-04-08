require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "generates account and cannot add duplicates" do
  	account = Account.generate("unit_test_account")
  	assert !account.nil?, "Account not created"
  	assert account.public_key.length == 43, "Failed generating public key"
  	assert account.private_key.length == 43, "Failed generating private key"
  	assert account.balance == 0, "Initialized with incorrect balance"
		exception = assert_raises(RuntimeError) { Account.generate("unit_test_account") }
		assert exception.message == "Cannot add duplicate name", "Not raised the correct exception"
	end
	test "generates url safe random keys" do
		(0..20).each do |x|
			random_key = Account.generate_random_key
			assert !(random_key !~ /^[a-zA-Z0-9_-]*$/), "Not URL safe"
			assert random_key.length == 43, "Not correct length"
		end
	end
end
