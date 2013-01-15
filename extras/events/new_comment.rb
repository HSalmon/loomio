class Events::NewComment < Event
  def self.publish(comment)
    event = create!(:kind => "new_comment", :eventable => comment,
                    :discussion_id => comment.discussion.id)
    event.notify_user!(comment)
  end

  def notify_user!(comment)
    comment.mentioned_group_members.each do |mentioned_user|
      Event.user_mentioned!(comment, mentioned_user)
    end
    comment.other_discussion_participants.each do |non_mentioned_user|
      notify!(non_mentioned_user)
    end
  end
end