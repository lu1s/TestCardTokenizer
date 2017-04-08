class Account < ApplicationRecord
	def self.generate(name)
		raise "Cannot add duplicate name" if Account.where(name: name).present?
		Account.create(name: name, public_key: self.generate_random_key, private_key: self.generate_random_key)
	end
	def self.generate_random_key
		k = SecureRandom.urlsafe_base64(32, false)
		if Account.where("public_key = '#{k}' or private_key = '#{k}'").present?
			generate_random_key
		end
		k
	end
end
