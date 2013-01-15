class Events::NewVote < Event
  def self.publish(vote)
    event = create!(:kind => "new_vote", :eventable => vote,
                      :discussion_id => vote.motion.discussion.id)
    event.notify_user!(vote)
  end

  def notify_user!(vote)
    voter = vote.user
    if voter != vote.motion_author
      notify!(vote.motion_author)
    end

    if voter != vote.discussion_author
      if vote.motion_author != vote.discussion_author
        notify!(vote.discussion_author)
      end
    end
  end
end