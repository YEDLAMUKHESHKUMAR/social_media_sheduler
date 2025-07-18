class PublishPostJob < ApplicationJob
  queue_as :default
  
  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post&.scheduled?
    
    begin
      case post.platform
      when 'linkedin'
        # Assuming you have a LinkedinPublishingService
        # LinkedinPublishingService.new(post).publish
        Rails.logger.info "Simulating LinkedIn post for post ID: #{post_id}"
        post.update(status: 'published') # Simulate for now
      when 'twitter'
        TwitterPublishingService.new(post).publish
      else
        raise "Unsupported platform: #{post.platform}"
      end
      Rails.logger.info "Successfully published scheduled post #{post_id} to #{post.platform}"
    rescue => e
      Rails.logger.error "Failed to publish scheduled post #{post_id}: #{e.message}"
      post.mark_as_failed!
      
      # Optionally, you could add retry logic here or send notifications
      # retry_job(wait: 5.minutes) if executions < 3
    end
  end
end
