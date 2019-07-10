require "rails_helper"

RSpec.describe "departments", type: :feature do

  describe 'index' do
    let!(:department1) { create(:department) }
    let!(:department2) { create(:department) }

    it "displays a list of all departments" do
      visit "/"
      expect(page).to have_content("Welcome to Course Review")
      expect(page).to have_content("Departments")
      click_link('Departments')
      within('table.departments') do
        expect(page).to have_content(department1.name)
        expect(page).to have_content(department2.name)
      end
      expect(page).not_to have_content('New Department')
    end
  end

  describe 'create, edit, and destroy a department' do
    let!(:department1) { create(:department) }
    let!(:department2) { create(:department) }

    it 'allows the user to create, edit, and destroy a Department' do
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
        expect(page).to have_content(department1.school.name)
        expect(page).to have_content(department2.school.name)
        click_link(department1.school.name)
      end
      expect(page).to have_content('New Department')

      click_link('New Department')
      within("#department_form") do
        fill_in 'Name', with: 'Unicornology'
        fill_in 'Short name', with: 'UNI'
      end
      click_button 'Submit'
      expect(page).to have_content('Department was successfully created.')
      expect(page).to have_content("Unicornology at #{department1.school.name}")
      click_link(department1.school.name)
      within('table.departments') do
        expect(page).to have_content('Unicornology')
        expect(page).to have_content('UNI')
      end

      within("tr#department_row_#{Department.last.id}") do
        click_link('Edit')
      end
      expect(page).to have_content('Editing Department')
      within("#department_form") do
        fill_in 'Name', with: 'Unicornology'
        fill_in 'Short name', with: 'UNIC'
      end
      click_button 'Submit'
      expect(page).to have_content('Department was successfully updated.')
      expect(page).to have_content('UNIC')
      click_link(department1.school.name)
      within('table.departments') do
        expect(page).to have_content('Unicornology')
        expect(page).to have_content('UNIC')
      end

      within("tr#department_row_#{Department.last.id}") do
        click_link('Delete')
      end
      expect(page).to have_content('Department was successfully destroyed.')
    end
  end
end