require 'spec_helper'

describe Event do
  let(:user) { stub(:user, email: 'jon@lemmon.com') }
  let(:event) { stub(:event, :notify! => true) }
  let(:mailer) { stub(:mailer, :deliver => true) }
  let(:discussion) { mock_model Discussion }
  let(:group) { stub(:group) }

  # before do
  #   Event.stub(:create!).and_return(event)
  # end

  describe "new_discussion!", isolated: true do
    let(:discussion) { stub(:discussion) }

    before do
      Event.stub(:create!).and_return(event)
      event.stub(:notify_user!)
      discussion.stub(:id).and_return(discussion.id)
    end

    after do
      Event.new_discussion!(discussion)
    end

    it 'creates an event with kind new_discussion and eventable discussion' do
      Event.should_receive(:create!).with(kind: 'new_discussion',
                                          eventable: discussion,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(discussion)
    end
  end

  describe "new_comment!", isolated: true do
    let(:comment) { stub(:comment) }

    before do
      Event.stub(:create!).and_return(event)
      comment.stub(:discussion).and_return(discussion)
      event.stub(:notify_user!)
    end

    after do
      Event.new_comment!(comment)
    end

    it 'creates an event with kind new_comment and eventable comment' do
      Event.should_receive(:create!).with(kind: 'new_comment',
                                          eventable: comment,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(comment)
    end
  end

  describe "new_motion!", isolated: true do
    let(:motion) { stub(:motion) }

    before do
      Event.stub(:create!).and_return(event)
      motion.stub(:discussion).and_return(discussion)
      event.stub(:notify_user!)
    end

    after do
      Event.new_motion!(motion)
    end

    it 'creates an event with kind new_motion and eventable motion' do
      Event.should_receive(:create!).with(kind: 'new_motion',
                                          eventable: motion,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(motion)
    end
  end

  describe "motion_closing_soon!", isolated: true do
    let(:motion) { stub(:motion) }

    before do
      Event.stub(:create!).and_return(event)
      event.stub(:notify_user!)
    end

    after do
      Event.motion_closing_soon!(motion)
    end

    it 'creates an event with kind motion_closing_soon and eventable motion' do
      Event.should_receive(:create!).with(kind: 'motion_closing_soon',
                                          eventable: motion).and_return(event)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(motion)
    end
  end

  describe "new_vote!", :isolated => true do
    let(:vote) { stub(:vote) }

    before do
      Event.stub(:create!).and_return(event)
      event.stub(:notify_user!)
      vote.stub_chain(:motion, :discussion).and_return(discussion)
    end

    after do
      Event.new_vote!(vote)
    end

    it 'creates an event with kind new_vote and eventable vote' do
      Event.should_receive(:create!).with(kind: 'new_vote',
                                          eventable: vote,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(vote)
    end
  end

  describe "motion_closed!" do
    let(:motion) { stub(:motion) }
    let(:closer) { stub(:user, :email => 'bill@dave.com') }

    before do
      Event.stub(:create!).and_return(event)
      event.stub(:notify_user!)
      motion.stub(:discussion).and_return(discussion)
      motion.stub(:author).and_return(closer)
      MotionMailer.stub_chain(:motion_closed, :deliver)
    end

    after do
      Event.motion_closed!(motion, closer)
    end

    it 'creates an event with kind motion_closed and eventable motion' do
      Event.should_receive(:create!).with(kind: 'motion_closed',
                                          eventable: motion,
                                          discussion_id: discussion.id,
                                          user: closer).and_return(event)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(motion, closer)
    end
  end

  describe "motion_blocked!" do
    let(:vote) { stub(:vote) }

    before do
      Event.stub(:create!).and_return(event)
      event.stub(:notify_user!)
      vote.stub_chain(:motion, :discussion).and_return(discussion)
    end

    after do
      Event.motion_blocked!(vote)
    end

    it 'creates an event with kind motion_blocked and eventable vote' do
      Event.should_receive(:create!).with(kind: 'motion_blocked',
                                          eventable: vote,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(vote)
    end
  end

  describe "membership_requested!", isolated: true do
    let(:membership) { stub(:membership) }

    before do
      Event.stub(:create!).and_return(event)
      event.stub(:notify_user!)
    end

    after do
      Event.membership_requested!(membership)
    end

    it 'creates an event with kind membership_requested and eventable membership' do
      Event.should_receive(:create!).with(kind: 'membership_requested',
                                          eventable: membership)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(membership)
    end
  end

  describe "user_added_to_group!", isolated: true do
    let(:membership) { stub(:membership, user: user) }

    before do
      Event.stub(:create!).and_return(event)
      event.stub(:notify_user!)
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

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(membership)
    end

    context 'accepted_or_not_invited is true' do
      before do
        user.stub(:accepted_or_not_invited?).and_return(true)
        user.should_receive(:accepted_or_not_invited?)
      end
      it 'delivers UserMailer.added_to_group' do
        UserMailer.should_receive(:added_to_group).with(membership).and_return(mailer)
      end
    end

    context 'accepted_or_not_invited is false' do
      before do
        user.should_receive(:accepted_or_not_invited?)
      end
      it 'does not deliver UserMailer.added_to_group' do
        UserMailer.should_not_receive(:added_to_group)
      end
    end
  end

  describe "comment_liked!", isolated: true do
    let(:commenter) { stub(:commenter) }
    let(:voter) { stub(:voter) }
    let(:comment_vote) { stub(:comment_vote,
                              comment_user: commenter,
                              user: voter) }

    before do
      Event.stub(:create!).and_return(event)
      event.stub(:notify_user!)
    end

    after do
      Event.comment_liked!(comment_vote)
    end

    it 'creates an event with kind comment_liked and eventable comment_vote' do
      Event.should_receive(:create!).with(kind: 'comment_liked',
                                          eventable: comment_vote)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(comment_vote)
    end
  end

  describe "user_mentioned!", isolated: true do
    let(:comment_author) { stub(:comment_author) }
    let(:comment) { stub(:comment, user: comment_author) }
    let(:mentioned_user) { stub(:mentioned_user,
                                :subscribed_to_mention_notifications? => false) }

    before do
      Event.stub(:create!).and_return(event)
      event.stub(:notify_user!)
    end

    after do
      Event.user_mentioned!(comment, mentioned_user)
    end

    it 'creates a user_mentioned event' do
      Event.should_receive(:create!).
        with(kind: 'user_mentioned', eventable: comment).
        and_return(event)
    end

    it 'calls notify_user! on event' do
      event.should_receive(:notify_user!).with(comment, mentioned_user)
    end
  end

  describe "discussion_title_edited!", isolated: true do
    let(:editor) { stub(:editor) }
    let(:discussion) { stub(:discussion) }

    before do
      Event.stub(:create!).and_return(event)
      discussion.stub(:id).and_return(discussion.id)
    end

    after do
      Event.discussion_title_edited!(discussion, editor)
    end

    it 'creates a discussion_title_edited event' do
      Event.should_receive(:create!).
        with(kind: 'discussion_title_edited', eventable: discussion,
          discussion_id: discussion.id, user: editor).and_return(event)
    end
  end

  describe "discussion_description_edited!", isolated: true do
    let(:editor) { stub(:editor) }
    let(:discussion) { stub(:discussion) }

    before do
      Event.stub(:create!).and_return(event)
      discussion.stub(:id).and_return(discussion.id)
    end

    after do
      Event.discussion_description_edited!(discussion, editor)
    end

    it 'creates a discussion_description_edited event' do
      Event.should_receive(:create!).
        with(kind: 'discussion_description_edited', eventable: discussion,
          discussion_id: discussion.id, user: editor).and_return(event)
    end
  end

  describe "motion_close_date_edited!", isolated: true do
    let(:editor) { stub(:editor) }
    let(:motion) { stub(:motion) }

    before do
      Event.stub(:create!).and_return(event)
      motion.stub(:discussion).and_return(discussion)
    end

    after do
      Event.motion_close_date_edited!(motion, editor)
    end

    it 'creates a motion_close_date_edited event' do
      Event.should_receive(:create!).
        with(kind: 'motion_close_date_edited', eventable: motion,
          discussion_id: discussion.id, user: editor).and_return(event)
    end
  end
end
