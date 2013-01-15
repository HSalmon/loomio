class Events::UserMentioned < Event
  def self.publish(comment, mentioned_user)
    event = create!(:kind => "user_mentioned", :eventable => comment)
    event.notify_user!(comment, mentioned_user)
  end

  def notify_user!(comment, mentioned_user)
    unless mentioned_user == comment.user
      if mentioned_user.subscribed_to_mention_notifications?
        UserMailer.mentioned(mentioned_user, comment).deliver
      end
      notify!(mentioned_user)
    end
  end
end