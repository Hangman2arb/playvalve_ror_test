# Playvalve RoR API

## Introduction

This Ruby on Rails API-only application provides an endpoint to perform a series of security checks to determine the ban status of a user based on specific criteria, including device integrity, IP checks for VPN/Tor usage, and country whitelisting.

## Technologies

- Ruby 3.2.3
- Ruby on Rails 7 (API mode)
- PostgreSQL
- Redis
- RSpec/FactoryBot for testing

## Installation

1. **Clone the repository:**
   ```
   git clone https://github.com/Hangman2arb/playvalve_ror_test.git
   cd playvalve_ror_test
   ```

2. **Setup Environment Variables:**
    - Ensure you have a `.env` file with necessary variables: `REDIS_URL` (default: "redis://localhost:6379/0") and `VPNAPI_KEY`.

3. **Install dependencies:**
   ```
   bundle install
   ```

4. **Database Setup:**
   ```
   rails db:create db:migrate
   ```

5. **Start the Redis server:**
    - Ensure Redis is installed and running on your system.
    - Ensure to set allowed_countries
      ```
      redis-cli
      SADD allowed_countries US CA UK
      ```

6. **Launch the application:**
   ```
   rails server
   ```

## Testing Scenarios

The application includes a comprehensive suite of RSpec tests that cover various scenarios to ensure the API behaves as expected:

1. **User Not Banned:** Verifies that a user is not banned when the IP country is whitelisted, the device is not rooted, and the IP is not identified as Tor or VPN.

2. **IP Country Whitelisting:** Tests that a user is banned if the IP country is not in the Redis whitelist.

3. **Rooted Device Check:** Ensures that a user is banned if the device is rooted.

4. **Tor/VPN IP Check:** Confirms that a user is banned if their IP is identified as coming from Tor or VPN.

5. **User Record Creation:** Checks that a new user record is created if the IDFA does not exist.

6. **User Record Update:** Verifies that an existing user's record is updated, and no new record is created if the IDFA already exists.

7. **Existing Banned User:** Ensures that a banned user remains banned without re-checking when their status is queried.

8. **Integrity Log Creation for New User:** Tests that a new `IntegrityLog` record is created when a new user is created.

9. **Integrity Log Creation for Ban Status Change:** Confirms that a new `IntegrityLog` record is created when an existing user's ban status changes.

To run these tests, execute the following command in the terminal:

```bash
rspec
```

This will run all the RSpec tests and provide a detailed output of each test case and its outcome.

## Using the Application with Postman

1. **Start the Rails server:**
   ```
   rails server
   ```

2. **Configure Postman:**
    - Set the method to `POST`.
    - URL: `http://localhost:3000/v1/user/check_status`
    - Headers:
        - Content-Type: application/json
        - X-Forwarded-For: [IP] (This is required because Postman always sends '::1' as the IP address.)
        - CF-IPCountry: [Country Code]
    - Body (raw JSON):
      ```json
      {
        "idfa": "8264148c-be95-4b2b-b260-6ee98dd53bf6",
        "rooted_device": false
      }
      ```
   
3. **Send the request and observe the response.**

The response will indicate the user's ban status based on the implemented security checks.

