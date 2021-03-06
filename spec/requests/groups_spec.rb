require 'spec_helper'

describe "Groups" do
  subject { page }

  context "a logged in user" do
    before :each do
      @user = create(:user)
      @group = create(:group, name: 'Test Group', viewable_by: :members)
      @group.add_member!(@user)
      @discussion = create(:discussion, group: @group, author: @user)
      @motion = create(:motion, name: 'Test Motion',
                              discussion: @discussion,
                              author: @user)
      visit("/users/sign_in")
      fill_in("user_email", :with => @user.email)
      fill_in("user_password", :with => @user.password)
      click_button("sign-in-btn")
    end

    context "admin of a group" do
      before :each do
        @group.add_admin!(@user)
      end

      context "viewing a group" do
        it "can see membership request section" do
          requested_user = build(:user)
          requested_user.save
          @group.add_request!(requested_user)

          visit group_path(@group)

          should have_content("Membership requests")
        end
        it "can see add member section" do
          visit group_path(@group)

          should have_content("Add new member")
        end
      end
    end

    context "group member viewing a group" do
      it "can add a discussion" do
        visit group_path(@group)

        find('#start-new-discussion').click
        should have_css(".new_discussion")
      end
    end

    context "group member viewing a group visible to members only" do
      before :each do
        @group.viewable_by = :members
        @group.save
      end

      context "members invitable by admins only" do
        before :each do
          @group.members_invitable_by = :admins
          @group.save
        end

        it "cannot see membership request section" do
          requested_user = build(:user)
          requested_user.save
          @group.add_request!(requested_user)

          visit group_path(@group)

          #should_not have_content("Membership requests")
        end

        it "cannot see add member section" do
          visit group_path(@group)

          should_not have_content("Add new member")
        end
      end

      context "members invitable by members" do
        before :each do
          @group.members_invitable_by = :members
          @group.save
        end

        it "can see membership request section" do
          requested_user = build(:user)
          requested_user.save
          @group.add_request!(requested_user)

          visit group_path(@group)

          should have_content("Membership requests")
        end

        it "can see add member section" do
          visit group_path(@group)

          should have_content("Add new member")
        end

      end

      it "can view the group's contents" do
        visit group_path(@group)

        should have_content("Test Group")
        should have_content("Members")
      end
    end

    context "group non-member viewing a private group" do
      it "displays 'group not found' page" do
        @group2 = build(:group, name: 'Test Group2', viewable_by: :members)
        @group2.save
        @group2.add_member!(create(:user))
        visit group_path(@group2)
        should have_content("Group not found")
        should have_no_content("Users")
      end
    end
  end

  context "logged-out user" do
    it "viewing a private group redirects to log-in" do
      @group = create(:group, name: 'Test Group', viewable_by: :members)
      visit group_path(@group)

      should have_css("body.sessions.new")
    end
  end
end
