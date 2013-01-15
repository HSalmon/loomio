require 'spec_helper'

describe NewComment do
  describe "#notify_users"

   describe "send_new_comment_notifications!" do
  #   before do
  #     user = stub(:user)
  #     discussion = create :discussion
  #     @comment = create :comment
  #     discussion.add_comment(user, @comment)
  #     @event = Event.create!(:kind => "new_comment", :eventable => @comment,
  #                     :discussion_id => @comment.discussion.id)

  #     @mentioned_user = stub(:user)
  #     @non_mentioned_user = stub(:user)
  #     @comment.stub(:mentioned_group_members).and_return([@mentioned_user])
  #     @comment.stub(:other_discussion_participants).and_return([@non_mentioned_user])
  #     @event.stub(:notify!)
  #     Event.stub(:user_mentioned!)
  #   end

  #   after do
  #     @event.send_new_comment_notifications!(@comment)
  #   end

  #   it 'fires a user_mentioned! event for each mentioned group member' do
  #     Event.should_receive(:user_mentioned!).with(@comment, @mentioned_user)
  #   end

  #   it 'calls event.notify! for each non mentioned group member' do
  #     @event.should_receive(:notify!).with(@non_mentioned_user)
  #   end
  # end
end