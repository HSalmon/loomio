require 'spec_helper'

describe MembershipRequested do
  describe "#notify_users"

    let(:membership) { stub(:membership) }

    before do
      Event.stub(:create!).and_return(event)
      membership.stub(:group_admins).and_return([user])
    end

    after do
      Event.membership_requested!(membership)
    end

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'membership_requested',
                                          eventable: membership)
    end

    it 'notifies group admins' do
      event.should_receive(:notify!).with(user)
    end

end