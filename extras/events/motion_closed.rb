class Events::MotionClosed < Event
  def self.publish(motion, closer)
    event = create!(:kind => "motion_closed", :eventable => motion, :user => closer,
                      :discussion_id => motion.discussion.id)
    event.notify_user!(motion, closer)
    MotionMailer.motion_closed(motion, motion.author.email).deliver
  end

  def notify_user!(motion, closer)
    motion.group_users.each do |user|
      unless user == closer
        notify!(user)
      end
    end
  end
end