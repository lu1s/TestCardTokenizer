require 'test_helper'

class CardTest < ActiveSupport::TestCase
  test "creates or updates and validates" do
  	valid_card_numbers = []
  	invalid_card_numbers = []
  	(0..10).each do |x|
  		cc_companies = [:maestro, :amex, :mastercard, :switch, :visa]
  		valid_card_numbers << CreditCardValidations::Factory.random(cc_companies[rand(cc_companies.size)])
  		invalid_card_numbers << "0#{(0...15).map{('0'..'9').to_a[rand(10)]}.join}"
  	end
  	valid_card_numbers.each do |number|
  		cvc = rand(101..850)
  		c = Card.secure_create_or_update(number,
	  			rand(Date.today.year..(Date.today + 10.year).year),
	  			rand(1..12),
	  			cvc)
  		assert !c.nil?, "card was not inserted"
  		assert cvc == Card.decrypt_secure_code(c.secure_code), "cvc was not encrypted correctly"
  		assert Card.valid?(number), "number can not be validated but it should be valid"
  		assert c.card_token.size == 43, "card token generated incorrectly"
  		assert Card.where(card_token: c.card_token).count == 1, "duplicate or lack of card token"
  		assert (c.token_timestamp + 10.minute) > DateTime.now, "card token timestamp is invalid"
  	end
  	current_cards = Card.count
  	invalid_card_numbers.each do |number|
  		cvc = rand(101..850)
  		c = Card.secure_create_or_update(number,
	  			rand(Date.today.year..(Date.today + 10.year).year),
	  			rand(1..12),
	  			cvc)
  		assert c.id.nil?, "card id should be nil because of rolled back transaction"
  		assert !Card.valid?(number), "card valid but should be invalid"
  	end
  	assert current_cards == Card.count, "any card should have been inserted by now"
  end
end
