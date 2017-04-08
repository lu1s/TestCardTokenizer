require 'test_helper'

class ChargeTest < ActiveSupport::TestCase
  test "charges can be applied to accounts" do
  	accounts = []
  	(0..10).each do |x| # 11
  		accounts << Account.generate((0...50).map { ('a'..'z').to_a[rand(26)] }.join)
  	end
  	assert accounts.count{|x| x.private_key.length == 43} == 11, "private key length failed"
  	assert accounts.count{|x| x.public_key.length == 43} == 11, "public key length failed"
  	accounts.each do |account|
  		card = Card.secure_create_or_update(CreditCardValidations::Factory.random(:maestro), 
  			rand(Date.today.year..(Date.today + 10.year).year),
  			rand(1..12),
  			rand(101..850))
  		assert (card.token_timestamp + 10.minute) > DateTime.now, "card token timestamp is invalid"
  		(0..5).each do |x|
	  		charge = Charge.create(account: account,
	  			card: card,
	  			amount: rand(10.50..250.50).to_d,
	  			charge_timestamp: DateTime.now)
	  		assert account.id == charge.account.id, "incorrect account set to charge"
	  		assert card.card_number == charge.card.card_number, "incorrect card set to charge"
  		end
  	end
  end
end
