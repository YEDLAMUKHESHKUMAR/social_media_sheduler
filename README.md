# Social Media Scheduler

A Ruby on Rails application for scheduling and managing social media posts for LinkedIn.

## Features

- User authentication with email/password
- LinkedIn OAuth integration
- Create, read, update, and delete posts
- Schedule posts for future publication
- Background job processing for scheduled posts
- Responsive UI for desktop and mobile devices

## Requirements

- Ruby 3.1.0+
- Rails 7.2.2+
- PostgreSQL 12+
- Redis (for background job processing)

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd social_media_scheduler
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   ```

4. Set up environment variables:
   Create a `.env` file in the root directory with the following variables:
   ```
   LINKEDIN_CLIENT_ID=your_linkedin_client_id
   LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
   SECRET_KEY_BASE=your_secret_key_base
   ```

5. Start the Redis server:
   ```bash
   sudo service redis-server start
   ```

6. Start the Sidekiq worker:
   ```bash
   bundle exec sidekiq
   ```

7. Start the Rails server:
   ```bash
   rails server
   ```

8. Visit `http://localhost:3000` in your browser.

## Usage

1. Sign up for an account or log in with existing credentials.
2. Connect your LinkedIn account via OAuth.
3. Create new posts and schedule them for future publication.
4. View, edit, or delete your posts from the dashboard.
5. Posts will be automatically published to LinkedIn at the scheduled time.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

