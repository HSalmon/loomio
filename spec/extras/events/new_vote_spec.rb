require 'spec_helper'

describe NewVote do
  describe "#notify_users"
    let(:motion_author) { stub(:motion_author) }
    let(:discussion_author) { stub(:discussion_author) }
    let(:vote) { stub(:vote,
                      user: user,
                      motion_author: motion_author,
                      discussion_author: discussion_author) }
    before do
      Event.stub(:create!).and_return(event)
      event.stub(:send_new_vote_notifications!).with(vote)
      vote.stub_chain(:motion, :discussion).and_return(discussion)
    end

    after do
      Event.new_vote!(vote)
    end

    it 'creates a new_vote event with eventable vote' do
      Event.should_receive(:create!).with(kind: 'new_vote',
                                          eventable: vote,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'calls send_new_vote_notifications!' do
      event.should_receive(:send_new_vote_notifications!)
    end

      describe "send_new_vote_notifications!" do
    let(:motion_author) { stub(:motion_author) }
    let(:discussion_author) { stub(:discussion_author) }

    before do
      user = stub(:user)
      discussion = create :discussion
      @comment = create :comment
      discussion.add_comment(user, @comment)
      @event = Event.create!(:kind => "new_comment", :eventable => @comment,
                      :discussion_id => @comment.discussion.id)
      @event.stub(:notify!)
    end

    after do
      @event.send_new_vote_notifications!(vote)
    end

    context 'voter is not the motion author but is the discussion author' do
      let(:vote) { stub(:vote,
                  user: discussion_author,
                  motion_author: motion_author,
                  discussion_author: discussion_author) }
      it 'notifies the motion author' do
        @event.should_receive(:notify!).once.with(motion_author)
      end
    end
    context 'voter is not the discussion author but is the motion author' do
      let(:vote) { stub(:vote,
            user: motion_author,
            motion_author: motion_author,
            discussion_author: discussion_author) }
      it 'notifies the discussion author' do
        @event.should_receive(:notify!).once.with(discussion_author)
      end
    end
    context 'voter is neither the discussion author nor the discussion author' do
      let(:vote) { stub(:vote,
            user: user,
            motion_author: motion_author,
            discussion_author: discussion_author) }
      it 'notifies the discussion author' do
        @event.should_receive(:notify!).with(discussion_author)
      end
      it 'notifies the motion author' do
        @event.should_receive(:notify!).with(motion_author)
      end
    end
    context 'voter is the discussion author and the discussion author' do
      let(:vote) { stub(:vote,
            user: user,
            motion_author: user,
            discussion_author: user) }
      it 'notifies the discussion author' do
        @event.should_not_receive(:notify!)
      end
      it 'notifies the motion author' do
        @event.should_not_receive(:notify!)
      end
    end
  end
end