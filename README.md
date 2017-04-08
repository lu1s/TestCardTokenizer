# Card Tokenization Emulator

This project is for testing purposes only.
It has the functionality to add and retrieve accounts, add and tokenize credit cards, and create charges to existing accounts using a valid credit card token.

## Prerequisites

Your system needs to have at least this software installed.

```bash
Ruby >= 2.3.0
Sqlite >= 3.14.1
```

## Installing

After cloning this repository just run the following commands.

```bash
$ bundle install
$ rails db:migrate
```

## Running the tests

To run the test just use the basic rails testing suite.

```bash
$ rails test
```

## Manually testing

Run the application and test with preferred http requestor.

### Run 

```bash
$ rails s ##should be now on http://localhost:3000
```

### Some calls

#### Create an account
```bash
$ curl -X POST --form "name=testname" http://localhost:3000/create_account
## {"success":true,"message":"OK","data":{"id":2,"name":"testname","private_key":"jN_j6wePGxPAbnb4inZQvIjUmdNQcjOtIrsH9-FNVT0","public_key":"NocZu8Nb_wUEa_xANHrJU_2vjhixkNw2_Zlzv1giXuQ","balance":"0.0","created_at":"2017-04-08T02:46:02.048Z","updated_at":"2017-04-08T02:46:02.048Z"}}
```

#### Retrieve an account key pair
```bash
$ curl -X POST --form "name=testname" http://localhost:3000/accounts
## {"success":true,"message":"OK","data":{"public_key":"AJ3Iw6r0G-kVERZKsKud83ygXAaiDhLXewWRbpUkG4U","private_key":"cWS_d4lwdDl-vQkies7TIbPfLI7Nf79O0_sRQC_ASx4"}}
```

#### Tokenize a card
```bash
$ curl -X POST --form 'card_number=4111111111111111' --form 'expiration_year=2020' --form 'expiration_month=2' --form 'secure_code=205' http://localhost:3000/tokenize 
## {"success":true,"message":"OK","data":{"token":"3YSCqXs1sXvsUEXyIeiEW8Xf_01q4CfyeZAYdVg32Zg","expires":"2017-04-07T19:57:15-07:00"}}
```

#### Create a charge with the tokenized card
```bash
$ curl -X POST --form "card_token=3YSCqXs1sXvsUEXyIeiEW8Xf_01q4CfyeZAYdVg32Zg" --form "amount=504.12" --form "account_name=testname" http://localhost:3000/charges
## {"success":true,"message":"OK","data":{}}
```





