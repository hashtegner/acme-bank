# AcmeBank
![](https://github.com/alesshh/acme-bank/workflows/Elixir%20CI/badge.svg)

A fictional bank app. Demo at [https://acme-bankx.herokuapp.com](https://acme-bankx.herokuapp.com).

## About

This app is a [POC](https://en.wikipedia.org/wiki/Proof_of_concept) writing in [Elixir](https://elixir-lang.org/) only using [Ecto](https://github.com/elixir-ecto/ecto) and [Plug](https://github.com/elixir-plug/plug).

## Getting started

### Dependencies

To run this app you need to install:

- Elixir 1.9.1 (asdf is the best way [https://github.com/asdf-vm/asdf](https://github.com/asdf-vm))
- Postgres 12 [https://www.postgresql.org/download/](https://www.postgresql.org/download/)
  - If you has docker and docker-compose [https://docs.docker.com/compose/](https://docs.docker.com/compose/), just run `docker-compose up`

### Setup

- Clone this project

```bash
 $ git clone https://github.com/alesshh/acme-bank.git
 ```
- Install elixir dependencies
```bash
$ mix deps.get
```
- Create and migrate database
```bash
$ mix ecto.create && mix ecto.migrate
```
- Running tests
```bash
$ MIX_ENV=test mix ecto.migrate && mix test
```
- Running the project
```bash
$ mix run --no-halt
```
## Available API and features

### Create a new account
```bash
curl --request POST \
  --url https://acme-bankx.herokuapp.com/accounts \
  --header 'content-type: application/json' \
  --data '{
	"name": "My Account"
}'
```
Response
```json
{
  "access_token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhY21lX2JhbmsiLCJleHAiOjE1NzU5Mjk4NjcsImlhdCI6MTU3MzUxMDY2NywiaXNzIjoiYWNtZV9iYW5rIiwianRpIjoiMzI2YmI5YjktNDUwZC00YWE0LWIxMjEtMDdiNjYyODRlNzMzIiwibmJmIjoxNTczNTEwNjY2LCJzdWIiOiI4ZDhlMWI3Ni04ZTkyLTRjMWQtOTdmZi1kMDA2ZTZkZWUzYWUiLCJ0eXAiOiJhY2Nlc3MifQ.SUunQjTHAZX1Y4kwlr6FWfInf7LjEkgNJaDGsdI4v_5JplbSp7Rivry_ycO-qR6pJplXCuduTJB0BYKJBZD3UQ",
  "account": {
    "id": "8d8e1b76-8e92-4c1d-97ff-d006e6dee3ae",
    "inserted_at": "2019-11-10T22:17:47",
    "name": "My Account",
    "updated_at": "2019-11-10T22:17:47"
  }
}
```
### Place money in account wallet
```bash
curl --request POST \
  --url 'https://acme-bankx.herokuapp.com/wallets/place' \
  --header 'authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhY21lX2JhbmsiLCJleHAiOjE1NzU5Mjk4NjcsImlhdCI6MTU3MzUxMDY2NywiaXNzIjoiYWNtZV9iYW5rIiwianRpIjoiMzI2YmI5YjktNDUwZC00YWE0LWIxMjEtMDdiNjYyODRlNzMzIiwibmJmIjoxNTczNTEwNjY2LCJzdWIiOiI4ZDhlMWI3Ni04ZTkyLTRjMWQtOTdmZi1kMDA2ZTZkZWUzYWUiLCJ0eXAiOiJhY2Nlc3MifQ.SUunQjTHAZX1Y4kwlr6FWfInf7LjEkgNJaDGsdI4v_5JplbSp7Rivry_ycO-qR6pJplXCuduTJB0BYKJBZD3UQ' \
  --header 'content-type: application/json' \
  --data '{
	"account_id": "8d8e1b76-8e92-4c1d-97ff-d006e6dee3ae",
	"amount_cents": 100
}'
```
Response
```json
{
  "account_id": "8d8e1b76-8e92-4c1d-97ff-d006e6dee3ae",
  "id": "c7ac71ca-e25c-4b14-bf8f-ec630a2c43eb",
  "inserted_at": "2019-11-10T22:16:28",
  "type": "place",
  "amount_cents": 100,
  "updated_at": "2019-11-10T22:16:28"
}
```

### Get wallet summary
```bash
curl --request GET \
  --url 'https://acme-bankx.herokuapp.com/wallets/summary?account_id=8d8e1b76-8e92-4c1d-97ff-d006e6dee3ae' \
  --header 'authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhY21lX2JhbmsiLCJleHAiOjE1NzU5Mjk3MjMsImlhdCI6MTU3MzUxMDUyMywiaXNzIjoiYWNtZV9iYW5rIiwianRpIjoiZDllZGE5MjYtNGJmMS00YTZjLTk4NDUtYTMxYzkxYmRjYzBlIiwibmJmIjoxNTczNTEwNTIyLCJzdWIiOiI2MWVjMGZmMC1jNmU4LTQzNzEtYjM4MC04NGU2ZGQ4OTdiYjgiLCJ0eXAiOiJhY2Nlc3MifQ.4DHDj4FhXcvm3m7emC_6lYeRWinzOWRiCVbU0Df5f8_kLu0XP70c_WL5EseNYJ9BgV_fFBkTWwlXsOh2-MXCiw' \
  --header 'content-type: application/json'
```
Response
```json
{
  "account_id": "8d8e1b76-8e92-4c1d-97ff-d006e6dee3ae",
  "amount_cents": 80000
}
```
### Transfer money between accounts
```bash
curl --request POST \
  --url https://acme-bankx.herokuapp.com/wallets/transfer \
  --header 'authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhY21lX2JhbmsiLCJleHAiOjE1NzU5Mjk3MjMsImlhdCI6MTU3MzUxMDUyMywiaXNzIjoiYWNtZV9iYW5rIiwianRpIjoiZDllZGE5MjYtNGJmMS00YTZjLTk4NDUtYTMxYzkxYmRjYzBlIiwibmJmIjoxNTczNTEwNTIyLCJzdWIiOiI2MWVjMGZmMC1jNmU4LTQzNzEtYjM4MC04NGU2ZGQ4OTdiYjgiLCJ0eXAiOiJhY2Nlc3MifQ.4DHDj4FhXcvm3m7emC_6lYeRWinzOWRiCVbU0Df5f8_kLu0XP70c_WL5EseNYJ9BgV_fFBkTWwlXsOh2-MXCiw' \
  --header 'content-type: application/json' \
  --data '{
	"source_account_id": "8d8e1b76-8e92-4c1d-97ff-d006e6dee3ae",
	"destination_account_id": "61ec0ff0-c6e8-4371-b380-84e6dd897bb8",
	"amount_cents": 20000
}'
```
Response
```json
{
  "destination_transaction": {
    "account_id": "61ec0ff0-c6e8-4371-b380-84e6dd897bb8",
    "id": "cf3e5bd4-c0d0-4529-91ac-28480290f0f8",
    "inserted_at": "2019-11-10T22:18:55",
    "type": "transfer",
    "amount_cents": 20000,
    "updated_at": "2019-11-10T22:18:55"
  },
  "source_transaction": {
    "account_id": "8d8e1b76-8e92-4c1d-97ff-d006e6dee3ae",
    "id": "0972a97e-5a62-4716-9a0b-44f24a62def7",
    "inserted_at": "2019-11-10T22:18:55",
    "type": "transfer",
    "amount_cents": -20000,
    "updated_at": "2019-11-10T22:18:55"
  }
}
```

## Contribute
- Fork this repository to your own GitHub account and then clone it to your local machine
- Make the necessary changes and ensure that tests are passing using `mix test`
- Send a pull request

### Best practices
- Make sure you don't have any source style issue, just run `mix format` and `mix credo`.