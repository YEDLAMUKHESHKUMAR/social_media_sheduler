class Post < ApplicationRecord
  belongs_to :user
  
  validates :content, presence: true, length: { maximum: 3000 }
  validates :status, presence: true, inclusion: { in: %w[draft scheduled published failed] }
  validates :platform, presence: true, inclusion: { in: %w[linkedin twitter] }

  attribute :error_message, :text

  scope :drafts, -> { where(status: 'draft') }
  scope :scheduled, -> { where(status: 'scheduled') }
  scope :published, -> { where(status: 'published') }
  scope :failed, -> { where(status: 'failed') }
  
  def draft?
    status == 'draft'
  end
  
  def scheduled?
    status == 'scheduled'
  end
  
  def published?
    status == 'published'
  end
  
  def failed?
    status == 'failed'
  end
  
  def ready_to_publish?
    scheduled? && scheduled_at.present? && scheduled_at <= Time.current
  end

  def mark_as_failed!(message = nil)
    update(status: 'failed', error_message: message)
  end
end
