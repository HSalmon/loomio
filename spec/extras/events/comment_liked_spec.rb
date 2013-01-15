require 'spec_helper'

describe CommentLiked do
  describe "#notify_users"

    let(:commenter) { stub(:commenter) }
    let(:voter) { stub(:voter) }
    let(:comment_vote) { stub(:comment_vote,
                              comment_user: commenter,
                              user: voter) }
    before do
      Event.stub(:create!).and_return(event)
    end

    after do
      Event.comment_liked!(comment_vote)
    end

    it 'creates a comment_liked event' do
      Event.should_receive(:create!).with(kind: 'comment_liked',
                                          eventable: comment_vote).
                                          and_return(event)
    end

    it 'notifies the comment author' do
      event.should_receive(:notify!).with(commenter)
    end

    context 'voter is commenter' do
      before do
        comment_vote.stub(:user).and_return(commenter)
      end

      it 'does not notify the user' do
        event.should_not_receive(:notify!).with(user)
      end
    end

end