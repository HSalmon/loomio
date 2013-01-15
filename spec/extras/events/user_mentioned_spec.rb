require 'spec_helper'

describe UserMentioned do
  describe "#notify_users"

    let(:comment_author) { stub(:comment_author) }
    let(:comment) { stub(:comment, user: comment_author) }
    let(:mentioned_user) { stub(:mentioned_user,
                                :subscribed_to_mention_notifications? => false) }

    before do
      Event.stub(:create!).and_return(event)
    end

    after do
      Event.user_mentioned!(comment, mentioned_user)
    end

    it 'creates a user_mentioned event' do
      Event.should_receive(:create!).
        with(kind: 'user_mentioned', eventable: comment).
        and_return(event)
    end

    it 'notifies the mentioned user' do
      event.should_receive(:notify!).with(mentioned_user)
    end

    context 'mentioned user is subscribed to email notifications' do
      before do
        mentioned_user.should_receive(:subscribed_to_mention_notifications?).and_return(true)
      end

      it 'emails the user to say they were mentioned' do
        UserMailer.should_receive(:mentioned).with(mentioned_user, comment).and_return(mailer)
      end
    end

    context 'mentioned user is comment author' do
      let(:mentioned_user) { comment_author }
      it 'does not notify the user' do
        event.should_not_receive(:notify!)
      end
    end
end