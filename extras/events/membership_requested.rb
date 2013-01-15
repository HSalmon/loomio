class Events::MembershipRequested < Event
  def self.publish(membership)
    event = create!(:kind => "membership_requested",
                      :eventable => membership)
    event.notify_user!(membership)
  end

  def notify_user!(membership)
    membership.group_admins.each do |admin|
      notify!(admin)
    end
  end
end