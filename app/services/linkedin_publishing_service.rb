class LinkedinPublishingService
  include HTTParty
  base_uri 'https://api.linkedin.com'
  
  def initialize(post)
    @post = post
    @user = post.user
  end
  
  def publish
    raise "User not connected to LinkedIn" unless @user.linkedin_connected?
    raise "Post content is empty" if @post.content.blank?
    
    response = self.class.post(
      '/v2/ugcPosts',
      headers: headers,
      body: post_payload.to_json
    )
    
    if response.success?
      linkedin_post_id = response.parsed_response['id']
      @post.mark_as_published!(linkedin_post_id)
      true
    else
      error_message = response.parsed_response['message'] || 'Unknown error occurred'
      Rails.logger.error "LinkedIn API Error: #{response.code} - #{error_message}"
      @post.mark_as_failed!
      raise "LinkedIn API Error: #{error_message}"
    end
  rescue => e
    Rails.logger.error "LinkedIn Publishing Error: #{e.message}"
    @post.mark_as_failed!
    raise e
  end
  
  private
  
  def headers
    {
      'Authorization' => "Bearer #{@user.linkedin_token}",
      'Content-Type' => 'application/json',
      'X-Restli-Protocol-Version' => '2.0.0'
    }
  end
  
  def post_payload
    {
      author: "urn:li:person:#{@user.uid}",
      lifecycleState: "PUBLISHED",
      specificContent: {
        "com.linkedin.ugc.ShareContent" => {
          shareCommentary: {
            text: @post.content
          },
          shareMediaCategory: "NONE"
        }
      },
      visibility: {
        "com.linkedin.ugc.MemberNetworkVisibility" => "PUBLIC"
      }
    }
  end
end

