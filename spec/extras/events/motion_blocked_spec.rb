require 'spec_helper'

describe MotionBlocked do
  describe "#notify_users"

    let(:vote) { stub(:vote, other_group_members: [user]) }

    before do
      Event.stub(:create!).and_return(event)
      vote.stub_chain(:motion, :discussion).and_return(discussion)
    end

    after do
      Event.motion_blocked!(vote)
    end

    it 'creates a motion_blocked event' do
      Event.should_receive(:create!).with(kind: 'motion_blocked',
                                          eventable: vote,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'notifies other group members' do
      vote.should_receive(:other_group_members).and_return([user])
      event.should_receive(:notify!).with(user)
    end
end