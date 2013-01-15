class Event < ActiveRecord::Base
  KINDS = %w[new_discussion discussion_title_edited discussion_description_edited new_comment
             new_motion new_vote motion_blocked motion_close_date_edited
             motion_closing_soon motion_closed membership_requested
             user_added_to_group comment_liked user_mentioned]

  has_many :notifications, :dependent => :destroy
  belongs_to :eventable, :polymorphic => true
  belongs_to :user

  validates_inclusion_of :kind, :in => KINDS
  validates_presence_of :eventable

  attr_accessible :kind, :eventable, :user, :discussion_id

  def notify!(user)
    notifications.create!(user: user)
  end

  def notify_user!(*params)
  end

  handle_asynchronously :notify_user!

  class << self
    def new_discussion!(*params)
      Events::NewDiscussion.publish(*params)
    end

    def new_comment!(*params)
      Events::NewComment.publish(*params)
    end

    def new_motion!(*params)
      Events::NewMotion.publish(*params)
    end

    def motion_closed!(*params)
      Events::MotionClosed.publish(*params)
    end

    def motion_closing_soon!(*params)
      Events::MotionClosingSoon.publish(*params)
    end

    def new_vote!(*params)
      Events::NewVote.publish(*params)
    end

    def motion_blocked!(*params)
      Events::MotionBlocked.publish(*params)
    end

    def membership_requested!(*params)
      Events::MembershipRequested.publish(*params)
    end

    def user_added_to_group!(*params)
      Events::UserAddedToGroup.publish(*params)
    end

    def comment_liked!(*params)
      Events::CommentLiked.publish(*params)
    end

    def user_mentioned!(*params)
      Events::UserMentioned.publish(*params)
    end

    def discussion_title_edited!(*params)
      Events::DiscussionTitleEdited.publish(*params)
    end

    def discussion_description_edited!(*params)
      Events::DiscussionDescriptionEdited.publish(*params)
    end

    def motion_close_date_edited!(*params)
      Events::MotionCloseDateEdited.publish(*params)
    end
  end
end
