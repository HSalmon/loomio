class Events::CommentLiked < Event
  def self.publish(comment_vote)
    event = create!(:kind => "comment_liked", :eventable => comment_vote)
    event.notify_user!(comment_vote)
  end

  def notify_user!(comment_vote)
    unless comment_vote.user == comment_vote.comment_user
      notify!(comment_vote.comment_user)
    end
  end
end