require 'spec_helper'

describe UserAddedToGroup do
  describe "#notify_users"

      let(:membership) { stub(:membership, user: user) }

    before do
      Event.stub(:create!).and_return(event)
      user.stub(:accepted_or_not_invited?).and_return(false)
    end

    after do
      Event.user_added_to_group!(membership)
    end

    it 'creates a user_added_to_group event' do
      Event.should_receive(:create!).with(kind: 'user_added_to_group',
                                          eventable: membership).
                                          and_return(event)
    end

    it 'notifies the user' do
      event.should_receive(:notify!).with(user)
    end

    context 'accepted_or_not_invited is true' do
      before do
        user.should_receive(:accepted_or_not_invited?).and_return(true)
      end

      it 'delivers UserMailer.added_to_group' do
        UserMailer.should_receive(:added_to_group).with(membership).and_return(mailer)
      end
    end

    context 'accepted_or_not_invited is false' do
      it 'does not deliver UserMailer.added_to_group' do
        UserMailer.should_not_receive(:added_to_group)
      end
    end
end