# Billetto Rails Test

A Rails application that integrates with the Billetto public API and provides event voting using Rails Event Store.

## Demo

https://billetto-rails-test.onrender.com/

## Features

- Fetches public events from the Billetto API
- Stores and displays event information
- Clerk-based authentication
- Upvote and downvote functionality for authenticated users
- Voting events persisted using Rails Event Store
- Vote count processing
- Automated tests using RSpec

## Tech Stack

- Ruby
- Ruby on Rails
- PostgreSQL
- Rails Event Store
- Clerk
- RSpec
- ActiveJob
- Solid Queue

## Requirements

- Ruby [4.0.6]
- Rails [8.1.3.1]
- PostgreSQL [17.4]

## Setup

Clone the repository:

```bash
git clone <git@github.com:vigneshblue/billetto_rails_test.git>
cd billetto_rails_test
```

Install dependencies:

```bash
bundle install
```

Create and migrate the database:

```bash
bin/rails db:create
bin/rails db:migrate
```
## Credential.yml

Update these in your credentials.yml file

```bash
db_username: <your-db-username>
db_password: <your-db-password>
billetto_api_keypair: <your-billetto-api-keypair>
 ```

## Environment Variables

The application requires credentials for external services.

Configure the required environment variables:

```bash
CLERK_SIGN_IN_URL=/sign_in
CLERK_SIGN_UP_URL=/sign_up
CLERK_SECRET_KEY=<your-api-key>
CLERK_PUBLISHABLE_KEY=<your-api-key>
```

For security, API keys and secrets are not committed to the repository.


## Running the Application

Start the Rails server:

```bash
bin/rails server
```

Visit:

```text
http://localhost:3000
```

## Importing Events

Public events can be imported from Billetto using:

```bash
bin/rails billetto:sync_events
```

syncing is added to recurring.yml to run every hour in production mode

## Running Tests

Run the complete test suite:

```bash
bundle exec rspec
```

Run a specific spec:

```bash
bundle exec rspec spec/integrations/billetto/events_spec.rb
```

Rails Event store web:

```text
http://localhost:3000/res
```