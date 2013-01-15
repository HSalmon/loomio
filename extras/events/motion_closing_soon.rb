class Events::MotionClosingSoon < Event
  def self.publish(motion)
    event = create!(:kind => "motion_closing_soon",
                      :eventable => motion)
    event.notify_user!(motion)
  end

  def notify_user!(motion)
    motion.group_users.each do |user|
      event.notifications.create!(:user => user)
      if user.subscribed_to_proposal_closure_notifications
        UserMailer.motion_closing_soon(user, motion).deliver!
      end
    end
  end
end