class Events::NewDiscussion < Event
  def self.publish(discussion)
    event = create!(:kind => "new_discussion", :eventable => discussion,
                      :discussion_id => discussion.id)
    event.notify_user!(discussion)
  end

  def notify_user!(discussion)
    discussion.group_users_without_discussion_author.each do |user|
      if user.email_notifications_for_group?(discussion.group)
        DiscussionMailer.new_discussion_created(discussion, user).deliver
      end
      notify!(user)
    end
  end
end