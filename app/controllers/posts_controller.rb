class PostsController < ApplicationController
  before_action :require_login
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_post_ownership, only: [:show, :edit, :update, :destroy]
  
  def index
    @posts = current_user.posts.order(created_at: :desc)
    @drafts = @posts.drafts
    @scheduled = @posts.scheduled
    @published = @posts.published
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.platform = 'twitter' 
    
    if @post.save
      if @post.scheduled?
        PublishPostJob.set(wait_until: @post.scheduled_at).perform_later(@post.id)
      end
      flash[:notice] = "Post created successfully!"
      redirect_to @post
    else
      flash.now[:alert] = "There was an error creating your post."
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    original_status = @post.status
    original_content = @post.content
    
    if @post.update(post_params)
      if @post.published? && original_content != @post.content && @post.twitter_post_id.present?
        service = TwitterPublishingService.new(@post)
        if service.edit
          flash[:notice] = "Post updated and republished to Twitter successfully!"
        else
          flash[:alert] = "Post updated but failed to update on Twitter."
        end
      elsif @post.scheduled?
        PublishPostJob.set(wait_until: @post.scheduled_at).perform_later(@post.id)
        flash[:notice] = "Post updated and scheduled successfully!"
      else
        flash[:notice] = "Post updated successfully!"
      end
      
      redirect_to @post
    else
      flash.now[:alert] = "There was an error updating your post."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @post.published? && @post.twitter_post_id.present?
      service = TwitterPublishingService.new(@post)
      service.delete
    end
    
    @post.destroy
    flash[:notice] = "Post deleted successfully!"
    redirect_to dashboard_path, status: :see_other
  end
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
  
  def check_post_ownership
    unless @post.user == current_user
      flash[:alert] = "You don't have permission to access this post."
      redirect_to dashboard_path
    end
  end
  
  def post_params
    params.require(:post).permit(:content, :scheduled_at, :status)
  end
end
