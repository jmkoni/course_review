# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'courses', type: :feature do
  describe 'index' do
    let!(:course1) { create(:course) }
    let!(:course2) { create(:course) }

    it 'displays a list of all courses' do
      visit '/'
      expect(page).to have_content('Welcome to Course Review')
      expect(page).to have_content('Courses')
      click_link('Courses')
      within('table.courses') do
        expect(page).to have_content(course1.name)
        expect(page).to have_content(course2.name)
      end
      expect(page).not_to have_content('New Course')
    end
  end

  describe 'create, edit, and destroy a course' do
    let!(:course1) { create(:course) }
    let!(:course2) { create(:course) }

    it 'allows the user to create, edit, and destroy a Course' do
      user = create(:admin)
      visit '/'
      click_link('Sign in')
      within('#new_user') do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '867-J3nny-5309!'
      end
      click_button 'Log in'
      expect(page).to have_content('Signed in successfully.')
      click_link('Departments')
      within('table.departments') do
        expect(page).to have_content(course1.department.name)
        expect(page).to have_content(course2.department.name)
        click_link(course1.department.name)
      end
      expect(page).to have_content('New Course')

      click_link('New Course')
      within('#course_form') do
        fill_in 'Name', with: 'Unicornology'
        fill_in 'Number', with: '1001'
      end
      click_button 'Submit'
      expect(page).to have_content('Course was successfully created.')
      expect(page).to have_content("Unicornology at #{course1.department.school.name}")
      click_link(course1.department.name)
      within('table.courses') do
        expect(page).to have_content('Unicornology')
        expect(page).to have_content('1001')
      end

      within("tr#course_row_#{Course.last.id}") do
        click_link('Edit')
      end
      expect(page).to have_content('Editing Course')
      within('#course_form') do
        fill_in 'Name', with: 'Unicornology'
        fill_in 'Number', with: '101'
      end
      click_button 'Submit'
      expect(page).to have_content('Course was successfully updated.')
      expect(page).to have_content('101')
      click_link(course1.department.name)
      within('table.courses') do
        expect(page).to have_content('Unicornology')
        expect(page).to have_content('101')
      end

      within("tr#course_row_#{Course.last.id}") do
        click_link('Delete')
      end
      expect(page).to have_content('Course was successfully destroyed.')
    end
  end
end
