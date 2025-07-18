# Technical Documentation

## Architecture

The Social Media Scheduler is built using the Ruby on Rails framework following the Model-View-Controller (MVC) architecture. The application integrates with LinkedIn's API for OAuth authentication and post publishing.

### Components

1. **Models**:
   - `User`: Manages user authentication and LinkedIn credentials
   - `Post`: Handles post content, scheduling, and publishing status

2. **Controllers**:
   - `UsersController`: Manages user registration and profile
   - `SessionsController`: Handles user authentication and OAuth callbacks
   - `PostsController`: Manages CRUD operations for posts

3. **Views**:
   - ERB templates for rendering HTML pages
   - Responsive CSS for mobile and desktop layouts

4. **Background Processing**:
   - Sidekiq for handling asynchronous job processing
   - Redis for storing job queues
   - `PublishPostJob` for publishing scheduled posts to LinkedIn

## Database Schema

### Users Table
```
id: integer (primary key)
name: string
email: string
password_digest: string
linkedin_id: string
linkedin_token: text
linkedin_refresh_token: text
created_at: datetime
updated_at: datetime
```

### Posts Table
```
id: integer (primary key)
user_id: integer (foreign key)
content: text
scheduled_at: datetime
status: string (draft, scheduled, published)
platform: string
published_at: datetime
created_at: datetime
updated_at: datetime
```

## Authentication

The application uses two authentication methods:

1. **Local Authentication**:
   - BCrypt for password hashing
   - Session-based authentication for logged-in users

2. **LinkedIn OAuth**:
   - OmniAuth middleware for handling OAuth flow
   - Stores LinkedIn tokens securely for API access

## Background Job Processing

Scheduled posts are managed through a background job system:

1. When a post is scheduled, a `PublishPostJob` is created and scheduled to run at the specified time.
2. Sidekiq processes the job queue and executes the publishing job when the scheduled time arrives.
3. The job uses the LinkedIn API to publish the post to the user's LinkedIn profile.
4. After successful publication, the post status is updated to "published".

## API Integration

### LinkedIn API

The application integrates with LinkedIn's API for:

1. **Authentication**: Using OAuth 2.0 protocol
2. **Profile Access**: Reading basic profile information
3. **Post Publishing**: Creating posts on the user's behalf

The integration is managed through the `LinkedinPublishingService` class, which handles API requests and error handling.

## Security Considerations

1. **Authentication**: 
   - Passwords are hashed using BCrypt
   - OAuth tokens are stored securely
   - CSRF protection is enabled

2. **Authorization**:
   - Users can only access their own posts
   - Controller actions verify ownership before allowing operations

3. **Environment Variables**:
   - Sensitive credentials are stored as environment variables
   - Not committed to version control

## Performance Optimizations

1. **Background Processing**:
   - Asynchronous job processing for scheduled posts
   - Reduces user-facing latency

2. **Database Indexes**:
   - Indexes on frequently queried columns
   - Optimized queries for dashboard views

3. **Caching**:
   - Fragment caching for dashboard components
   - Reduces database load for frequently accessed data

