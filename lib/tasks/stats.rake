namespace :stats do
  task :groups => :environment do    # Export all groups, scramble details of private ones
    groups_csv_file = AWS::S3.new.buckets['loomio-public-log'].objects.create 'groups.csv'

    require 'csv'
    c = CSV.generate do |csv|
      csv << ["id", "name", "created_at", "viewable_by", "parent_id", "description", "memberships_count", "archived_at"]
      Group.all.each do |group|
        if group.viewable_by == :everyone
          csv << [group.id, group.name, group.created_at, group.viewable_by, group.parent_id, group.description, group.memberships_count, group.archived_at]
        else
          csv << [Digest::MD5.hexdigest(group.id.to_s), "Private", group.created_at, group.viewable_by, group.parent_id, "Private", group.memberships_count, group.archived_at]
        end
      end
    end

    groups_csv_file.write c
  end

  task :users => :environment do   # Export all users' create dates
    users_csv_file = AWS::S3.new.buckets['loomio-public-log'].objects.create 'users.csv'

    require 'csv'
    c = CSV.generate do |csv|
      csv << ["id", "created_at", "memberships_count"]
      User.all.each do |user|
        csv << [Digest::MD5.hexdigest(user.id.to_s), user.created_at, user.memberships_count]
      end
    end

    users_csv_file.write c
  end

task :events => :environment do    # Export all events, scramble users, scramble private groups & subgroups
    events_csv_file = AWS::S3.new.buckets['loomio-public-log'].objects.create 'events.csv'

    require 'csv'

    c = CSV.generate do |csv|
      csv << ["id", "user", "group", "parent_group", "kind", "created_at"]
      Event.all.each do |event|
        id = event.id
        kind = event.kind
        created_at = event.created_at
        eventable = event.eventable
        case event.kind
        when "new_discussion", "new_motion"
          user = eventable.author if eventable
          group = eventable.group if eventable
        when "new_comment", "new_vote", "motion_blocked", "membership_requested", "comment_liked", "mentioned_user"
          begin
            user = eventable.user if eventable
            group = eventable.group if eventable
          rescue => error
            puts error.class
            puts error
            user = nil
            group = nil
          end
        when "motion_closed"
          user = event.user
          group = eventable.group if eventable
        when "user_added_to_group"
          user = eventable.inviter if eventable
          group = eventable.group if eventable
        else
          user = nil
          group = nil
        end

        user_id = user ? user.id : ""

        # scramble users, and (private) groups & subgroups

        user_id = Digest::MD5.hexdigest(user_id.to_s)

        if group
          if group.viewable_by == :everyone
            group_id = group.id
          else
            group_id = Digest::MD5.hexdigest(group.id.to_s)
          end

          if group.parent and group.viewable_by == :everyone
            parent_group_id = group.parent.id.to_s
          elsif group.parent  # i.e. the group is not public
            parent_group_id = Digest::MD5.hexdigest(group.parent.id.to_s)
          else
            parent_group_id =  ""
          end
        end

        csv << [id, user_id, group_id, parent_group_id, kind, created_at]
      end
    end
    events_csv_file.write c
  end
end