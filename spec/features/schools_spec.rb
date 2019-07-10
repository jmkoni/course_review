require "rails_helper"

RSpec.describe "schools", type: :feature do

  describe 'index' do
    let!(:school1) { create(:school) }
    let!(:school2) { create(:school) }

    it "displays a list of all schools" do
      visit "/"
      expect(page).to have_content("Welcome to Course Review")
      expect(page).to have_content("Schools")
      click_link('Schools')
      within('table.schools') do
        expect(page).to have_content(school1.name)
        expect(page).to have_content(school2.name)
      end
      expect(page).not_to have_content('New School')
    end
  end

  describe 'create, edit, and destroy a school' do
    let!(:school1) { create(:school) }
    let!(:school2) { create(:school) }

    it 'allows the user to create, edit, and destroy a school' do
      user = create(:admin)
      visit "/"
      click_link('Sign in')
      within("#new_user") do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '867-J3nny-5309!'
      end
      click_button 'Log in'
      expect(page).to have_content('Signed in successfully.')
      click_link('Schools')
      within('table.schools') do
        expect(page).to have_content(school1.name)
        expect(page).to have_content(school2.name)
      end
      expect(page).to have_content('New School')

      click_link('New School')
      within("#school_form") do
        fill_in 'Name', with: 'Unicorn University'
        fill_in 'Short name', with: 'UNIU'
      end
      click_button 'Submit'
      expect(page).to have_content('School was successfully created.')
      within('table.schools') do
        expect(page).to have_content('Unicorn University')
        expect(page).to have_content('UNIU')
      end

      within("tr#school_row_#{School.last.id}") do
        click_link('Edit')
      end
      expect(page).to have_content('Editing School')
      within("#school_form") do
        fill_in 'Name', with: 'Unicorn University'
        fill_in 'Short name', with: 'UU'
      end
      click_button 'Submit'
      expect(page).to have_content('School was successfully updated.')
      within('table.schools') do
        expect(page).to have_content('Unicorn University')
        expect(page).to have_content('UU')
      end

      within("tr#school_row_#{School.last.id}") do
        click_link('Delete')
      end
      expect(page).to have_content('School was successfully destroyed.')
    end
  end
end