# User Guide

## Getting Started

Welcome to the Social Media Scheduler! This guide will help you navigate the application and make the most of its features.

### Creating an Account

1. Visit the application at `http://localhost:3000`.
2. Click on "Sign Up" in the navigation bar.
3. Fill in your name, email, and password.
4. Click "Create Account" to register.
5. You will be automatically logged in and redirected to the dashboard.

### Logging In

1. Visit the application at `http://localhost:3000`.
2. Click on "Login" in the navigation bar.
3. Enter your email and password.
4. Click "Log In" to access your account.

### Connecting with LinkedIn

To publish posts to LinkedIn, you need to connect your LinkedIn account:

1. Go to your "Profile" page by clicking on "Profile" in the navigation bar.
2. Click on the "Connect with LinkedIn" button.
3. You will be redirected to LinkedIn to authorize the application.
4. Grant the requested permissions.
5. You will be redirected back to the application with your LinkedIn account connected.

## Managing Posts

### Creating a Post

1. From the dashboard, click on "Create New Post".
2. Enter your post content in the text area.
3. Choose a status:
   - **Save as Draft**: Save the post for later editing.
   - **Schedule for Later**: Set a future date and time for publication.
4. If scheduling, select the date and time for publication.
5. Click "Create Post" to save your post.

### Viewing Posts

1. All your posts are displayed on the dashboard.
2. Posts are organized by status: Drafts, Scheduled, and Published.
3. Click on a post to view its details.

### Editing a Post

1. From the dashboard, find the post you want to edit.
2. Click on the "Edit" button next to the post.
3. Make your changes to the content or scheduling.
4. Click "Update Post" to save your changes.

### Deleting a Post

1. From the dashboard, find the post you want to delete.
2. Click on the "Delete" button next to the post.
3. The post will be permanently deleted.

## Post Scheduling

### Scheduling a Post

1. When creating or editing a post, select "Schedule for Later" as the status.
2. Choose the date and time when you want the post to be published.
3. Click "Create Post" or "Update Post" to confirm.
4. The post will appear in the "Scheduled" section of your dashboard.

### How Scheduling Works

1. Scheduled posts are automatically published to LinkedIn at the specified time.
2. The application uses background processing to handle scheduled posts, so you don't need to be logged in for posts to be published.
3. After a post is published, its status changes to "Published" and it moves to the "Published" section of your dashboard.

## Profile Management

### Viewing Your Profile

1. Click on "Profile" in the navigation bar.
2. Your profile page displays your account information and LinkedIn connection status.

### Updating Your Profile

1. Go to your profile page.
2. Click on "Edit Profile".
3. Update your name, email, or password.
4. Click "Update Profile" to save your changes.

### Logging Out

1. Click on "Logout" in the navigation bar.
2. You will be logged out and redirected to the login page.

## Troubleshooting

### LinkedIn Connection Issues

If you encounter issues connecting to LinkedIn:

1. Ensure you have a valid LinkedIn account.
2. Try disconnecting and reconnecting your LinkedIn account.
3. Check if your LinkedIn token has expired and reconnect if necessary.

### Scheduled Posts Not Publishing

If your scheduled posts are not being published:

1. Verify that the Sidekiq worker is running (`bundle exec sidekiq`).
2. Check that Redis server is running (`sudo service redis-server start`).
3. Ensure your LinkedIn connection is valid and has the necessary permissions.

### Other Issues

For any other issues or questions:

1. Check the application logs for error messages.
2. Restart the application and try again.
3. Contact the administrator for further assistance.

