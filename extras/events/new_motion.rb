class Events::NewMotion < Event
  def self.publish(motion)
    event = create!(:kind => "new_motion", :eventable => motion,
                      :discussion_id => motion.discussion.id)
    event.notify_user!(motion)
  end

  def notify_user!(motion)
    motion.group_users_without_motion_author.each do |user|
      if user.email_notifications_for_group?(motion.group)
        MotionMailer.new_motion_created(motion, user).deliver
      end
      notify!(user)
    end
  end
end