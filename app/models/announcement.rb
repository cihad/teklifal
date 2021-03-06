class Announcement < ApplicationRecord
  DURATION_DAYS = [3, 10, 30]

  # Scopes
  scope :with_user_present, -> { where.not(user: nil) }
  scope :published, -> { where('expired_at > ?', Time.now) }
  scope :unpublished, -> { where('expired_at < ?', Time.now) }
  scope :archived, -> { unscoped.where(archived: true) }
  scope :not_archived, -> { where(archived: false) }
  scope :supervisors, -> { published.
    where.not(supervisor_id: nil).
    group(:supervisor_id).
    order("count_all asc")
  }

  # Associations
  has_many :offers, dependent: :destroy
  has_many :attachments, as: :attachmentable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true,
    reject_if: ->(attrs){ attrs[:file].blank? } 
  belongs_to :user, required: false
  belongs_to :supervisor, class_name: "User", required: false
  belongs_to :content, polymorphic: true, dependent: :destroy, optional: true
  accepts_nested_attributes_for :content, allow_destroy: true

  # Validates  
  validates_presence_of :title, :desc, :expired_at, :duration_day
  validates_inclusion_of :duration_day, in: DURATION_DAYS
  before_validation :set_supervisor, on: :create

  def content_type
    super or "PlainAnnouncement"
  end

  def content
    super or PlainAnnouncement.new(announcement_id: id)
  end

  def owner? user
    self.user == user
  end

  def duration_day= day
    self.expired_at = day.to_i.days.from_now
    super day
  end

  def published?
    # use try for initial nil expired_at value
    expired_at.try :>, Time.now
  end

  def expired?
    expired_at < Time.now
  end

  def expire!
    update_attribute :expired_at, Time.now
  end

  def archive!
    expire!
    update_attribute :archived, true
  end

  def content_type_name
    if content_type
      type_name = content_type.underscore
      type_name.slice! "_announcement"
      type_name
    end
  end

  def status
    if archived?
      :archived
    elsif published?
      :published
    elsif expired?
      :expired
    end
  end

  def subscribers
    "#{content_type}Subscription".
      safe_constantize.
      all.
      includes(:subscriber).
      where("filter->>'make' = ?", content.make).
      map(&:subscriber)
  end

  private

  def set_supervisor
    self.supervisor = User.lazy
  end
end
