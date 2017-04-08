class Charge < ApplicationRecord
  belongs_to :account
  belongs_to :card
end
