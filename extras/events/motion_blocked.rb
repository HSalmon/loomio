class Events::MotionBlocked < Event
  def self.publish(vote)
    event = create!(:kind => "motion_blocked", :eventable => vote,
                      :discussion_id => vote.motion.discussion.id)
    event.notify_user!(vote)
  end

  def notify_user!(vote)
    vote.other_group_members.each do |user|
      notify!(user)
    end
  end
end