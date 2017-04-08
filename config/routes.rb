Rails.application.routes.draw do
  post '/accounts', to: 'accounts#get_account'
  post '/create_account', to: 'accounts#create_account'
  get '/account_charges/:name', to: 'accounts#list_charges'
  post '/tokenize', to: 'tokenize#tokenize'
  post '/charges', to: 'charges#create_charge'
end
