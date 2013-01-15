require 'spec_helper'

describe NewDiscussion do
  describe "#notify_users"


    Event.stub(:create!).and_return(event)
      user.stub(:email_notifications_for_group?).and_return(false)
      motion.stub(:group_users_without_motion_author).and_return([user])
      motion.stub(:group_email_new_motion?).and_return(false)
      motion.stub(:discussion).and_return(discussion)
    end

    after do
      Event.new_motion!(motion)
    end

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_motion', 
                                          eventable: motion,
                                          discussion_id: discussion.id)
    end

    context 'if user is subscribed to group notification emails' do
      before do
        user.should_receive(:email_notifications_for_group?).with(motion.group).and_return(true)
      end

      it 'emails group_users_without_motion_author new_motion_created' do
        MotionMailer.should_receive(:new_motion_created).with(motion, user).and_return(mailer)
      end
    end

    context 'if user is not subscribed to group notification emails' do
      before do
        user.should_receive(:email_notifications_for_group?).with(motion.group).and_return(false)
      end

      it 'does not email new motion created' do
        MotionMailer.should_not_receive(:new_motion_created)
      end
    end

    it 'notifies group_users_without_motion_author' do
      event.should_receive(:notify!).with(user)
    end

    
end