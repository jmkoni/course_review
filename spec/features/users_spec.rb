require "rails_helper"

RSpec.describe "users", type: :feature do

  describe 'index' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    it "does not display users link" do
      visit "/"
      expect(page).to have_content("Welcome to Course Review")
      expect(page).not_to have_content("Users")
    end
  end

  describe 'create, edit, and destroy a user' do
    let!(:user1) { create(:user, email: 'pony@party.com') }
    let!(:user2) { create(:user, email: 'unicorns@rainbows.com') }

    it 'allows the user to create, edit, and destroy a user' do
      user = create(:admin)
      visit "/"
      click_link('Sign in')
      within("#new_user") do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '867-J3nny-5309!'
      end
      click_button 'Log in'
      expect(page).to have_content('Signed in successfully.')
      click_link('Users')
      within('table.users') do
        expect(page).to have_content(user1.email)
        expect(page).to have_content(user2.email)
      end

      user = User.first

      within("tr#user_row_#{user.id}") do
        expect(page).to have_content('Deactivate')
        click_link('Deactivate')
      end
      expect(page).to have_content('pony@party.com was successfully deactivated.')

      within("tr#user_row_#{user.id}") do
        expect(page).to have_content('Reactivate')
        click_link('Reactivate')
      end
      expect(page).to have_content('pony@party.com was successfully reactivated.')

      within("tr#user_row_#{user.id}") do
        expect(page).to have_content('Promote')
        click_link('Promote')
      end
      expect(page).to have_content('pony@party.com was successfully promoted to admin.')

      within("tr#user_row_#{user.id}") do
        expect(page).to have_content('Demote')
        click_link('Demote')
      end
      expect(page).to have_content('pony@party.com was successfully demoted from admin.')
    end
  end
end