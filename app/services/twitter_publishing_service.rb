require 'oauth'
require 'json'
require 'uri'

class TwitterPublishingService
  def initialize(post)
    @post = post
    @user = post.user
  end

  def publish
    begin
      # Create the OAuth consumer with your app's credentials
      consumer = OAuth::Consumer.new(
        ENV['TWITTER_API_KEY'],
        ENV['TWITTER_API_SECRET'],
        site: 'https://api.twitter.com'
       )

      # Create the access token for the user
      access_token = OAuth::AccessToken.new(
        consumer,
        @user.twitter_token,
        @user.twitter_secret
      )

      # Prepare the tweet payload
      payload = { text: @post.content }

      # Make the POST request to the Twitter API v2 endpoint
      response = access_token.post(
        'https://api.twitter.com/2/tweets',
        payload.to_json,
        { 'Content-Type' => 'application/json' }
       )

      # Parse the response
      parsed_response = JSON.parse(response.body)

      if response.code.to_i == 201 || response.code.to_i == 200
        # Tweet was successfully posted
        # Store the tweet ID from the response
        tweet_id = parsed_response['data']['id']
        @post.update(status: 'published', twitter_post_id: tweet_id)
        Rails.logger.info "Successfully published post #{@post.id} to Twitter. Tweet ID: #{tweet_id}"
      else
        # Handle error
        error_message = parsed_response['detail'] || parsed_response['errors']&.first&.dig('message') || 'Unknown error'
        @post.mark_as_failed!(error_message)
        Rails.logger.error "Failed to publish post #{@post.id} to Twitter. Status: #{response.code}, Error: #{error_message}"
        raise "Twitter API Error: #{response.code} - #{error_message}"
      end
    rescue => e
      @post.mark_as_failed!(e.message)
      Rails.logger.error "Twitter publishing failed for post ID: #{@post.id} - #{e.message}"
      raise # Re-raise to be caught by the job for retry/error handling
    end
  end

  def delete
    begin
      # Check if we have a Twitter post ID to delete
      unless @post.twitter_post_id.present?
        Rails.logger.error "Cannot delete post #{@post.id} from Twitter: No Twitter post ID found"
        return false
      end

      # Create the OAuth consumer with your app's credentials
      consumer = OAuth::Consumer.new(
        ENV['TWITTER_API_KEY'],
        ENV['TWITTER_API_SECRET'],
        site: 'https://api.twitter.com'
       )

      # Create the access token for the user
      access_token = OAuth::AccessToken.new(
        consumer,
        @user.twitter_token,
        @user.twitter_secret
      )

      # Make the DELETE request to the Twitter API v2 endpoint
      response = access_token.delete(
        "https://api.twitter.com/2/tweets/#{@post.twitter_post_id}"
       )

      # Parse the response if there is a body
      parsed_response = JSON.parse(response.body) if response.body.present?

      if response.code.to_i == 200
        # Tweet was successfully deleted
        @post.update(twitter_post_id: nil)
        Rails.logger.info "Successfully deleted post #{@post.id} from Twitter."
        return true
      else
        # Handle error
        error_message = parsed_response&.dig('detail') || parsed_response&.dig('errors', 0, 'message') || 'Unknown error'
        Rails.logger.error "Failed to delete post #{@post.id} from Twitter. Status: #{response.code}, Error: #{error_message}"
        return false
      end
    rescue => e
      Rails.logger.error "Twitter deletion failed for post ID: #{@post.id} - #{e.message}"
      return false
    end
  end

  def edit
    begin
      # First, delete the existing tweet
      old_tweet_id = @post.twitter_post_id
      
      if old_tweet_id.present?
        # Store the current status to revert if needed
        original_status = @post.status
        
        # Delete the existing tweet
        delete_result = delete
        
        # If deletion failed, log and return false
        unless delete_result
          Rails.logger.error "Failed to edit post #{@post.id} on Twitter: Could not delete existing tweet"
          return false
        end
        
        # Now publish the updated content as a new tweet
        publish
        
        # If the post is now published, the edit was successful
        if @post.published?
          Rails.logger.info "Successfully edited post #{@post.id} on Twitter. Old tweet ID: #{old_tweet_id}, New tweet ID: #{@post.twitter_post_id}"
          return true
        else
          Rails.logger.error "Failed to edit post #{@post.id} on Twitter: Could not publish updated content"
          return false
        end
      else
        # If there's no existing tweet ID, just publish as new
        Rails.logger.info "No existing tweet found for post #{@post.id}. Publishing as new."
        publish
        return @post.published?
      end
    rescue => e
      Rails.logger.error "Twitter edit failed for post ID: #{@post.id} - #{e.message}"
      return false
    end
  end
end
