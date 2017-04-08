class Card < ApplicationRecord
	validates :card_number, credit_card_number: {brands: [:amex, :maestro, :mastercard, :switch, :visa]}
	def self.valid?(number)
		(CreditCardValidations::Detector.new(number)).valid?
	end
	def self.encrypt_secure_code(code)
		crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
		crypt.encrypt_and_sign code
	end
	def self.decrypt_secure_code(encripted_code)
		crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
		crypt.decrypt_and_verify encripted_code
	end
	def self.generate_random_token
		k = SecureRandom.urlsafe_base64(32, false)
		if Card.where(card_token: k).present?
			generate_random_token
		end
		k
	end
	def self.secure_create_or_update(card_number, expiration_year, expiration_month, secure_code)
		if Card.where(card_number: card_number).present?
			card = Card.where(card_number: card_number).first
			card.update_attributes(expiration_year: expiration_year,
				expiration_month: expiration_month,
				secure_code: self.encrypt_secure_code(secure_code),
				token_timestamp: DateTime.now,
				card_token: self.generate_random_token)
		else
			card = Card.create(card_number: card_number, 
				expiration_year: expiration_year,
				expiration_month: expiration_month,
				secure_code: self.encrypt_secure_code(secure_code), 
				card_token: self.generate_random_token,
				token_timestamp: DateTime.now)
		end
		card
	end
end
