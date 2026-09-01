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

## Design Choices & Assumptions

- **External API integration:** Billetto API communication is isolated under `app/integrations/billetto`. The integration is split into separate `Client` and `Events` classes to keep responsibilities separate and make it easier to extend for future APIs.

- **Event creation and updates:** The application creates local events based on the events returned by the Billetto API. During recurring synchronization, only new events are created; existing events are not updated. This assumes that the API response provides the events that need to be synchronized and that updating existing events is not required for the scope of this assignment.

- **Domains:** `app/domains/billetto_event.rb` contains the domain logic related to voting and Rails Event Store interactions, keeping event-store logic separate from controllers.

- **Event handlers:** `app/events` contains event handlers for processing domain events in a dedicated location.

- **Background jobs:** I chose ActiveJob with Solid Queue because it is included with Rails and avoids introducing an additional dependency such as Redis for background job processing.

- **Clerk sign-in/sign-up:** I used Clerk's mountable components instead of redirecting users directly to Clerk's hosted URLs, which gives the application more control over the authentication UI.

- **Vote count calculation:** Vote counts are calculated by replaying the event stream rather than maintaining persisted counters. This keeps the event stream as the single source of truth and avoids having to keep a separate counter in sync with the events. I considered this approach sufficient for the scope of this project. The trade-off is that replaying events can become more expensive as the number of events grows or under higher traffic. At larger scale, this could be addressed using read models or projections.

- **Testing:** I chose RSpec instead of Minitest because I find RSpec's descriptive syntax easier to read and understand, particularly for request and system tests.

- **Pagination:** Events are paginated to avoid loading the entire event collection into memory and to keep the listing responsive as the number of events grows.


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