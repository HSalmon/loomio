require 'spec_helper'

describe MotionClosed do
  describe "#notify_users"

    let(:user) { stub(:user) }
    let(:closer) { stub(:user, :email => 'bill@dave.com') }
    let(:motion) { stub(:motion, :group => group) }

    before do
      Event.stub(:create!).and_return(event)
      motion.stub(:discussion).and_return(discussion)
      motion.stub(:author).and_return(closer)
      motion.stub(:group_users).and_return([user])
      MotionMailer.stub_chain(:motion_closed, :deliver)
    end

    after do
      Event.motion_closed!(motion, closer)
    end

    it 'emails group_users motion_closed' do
      MotionMailer.should_receive(:motion_closed).with(motion, closer.email).and_return(mailer)
    end

    it 'creates a motion_closed event' do
      Event.should_receive(:create!).with(kind: 'motion_closed',
                                          eventable: motion,
                                          user: closer,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'notifies other group members' do
      event.should_receive(:notify!).with(user)
    end

    it 'does not notify other the closer' do
      event.should_not_receive(:notify!).with(closer)
    end
end