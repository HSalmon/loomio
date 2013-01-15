class Events::UserAddedToGroup < Event
  def self.publish(membership)
    event = create!(:kind => "user_added_to_group", :eventable => membership)
    event.notify_user!(membership)

    # Send email only if the user has already accepted invitation to Loomio
    if membership.user.accepted_or_not_invited?
      UserMailer.added_to_group(membership).deliver
    end
  end

  def notify_user!(membership)
    notify!(membership.user)
  end
end