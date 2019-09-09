# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'reviews', type: :feature do
  describe 'index' do
    let!(:review1) { create(:review) }
    let!(:review2) { create(:review) }

    it 'displays a list of all reviews' do
      visit '/'
      expect(page).to have_content('Welcome to Course Review')
      expect(page).to have_content('Reviews')
      click_link('Reviews')
      within('table.reviews') do
        expect(page).to have_content(review1.course.name)
        expect(page).to have_content(review1.notes)
        expect(page).to have_content(review2.course.name)
      end
      expect(page).not_to have_content('New Review')
    end
  end

  describe 'create, edit, and destroy a review as standard user' do
    let!(:review1) { create(:review) }
    let!(:review2) { create(:review) }

    it 'allows the user to create, edit, and destroy a Review' do
      user = create(:user)
      visit '/'
      click_link('Sign in')
      within('#new_user') do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '867-J3nny-5309!'
      end
      click_button 'Log in'
      expect(page).to have_content('Signed in successfully.')
      click_link('Courses')
      within('table.courses') do
        expect(page).to have_content(review1.course.name)
        expect(page).to have_content(review2.course.name)
        click_link(review1.course.name)
      end
      expect(page).to have_content('New Review')

      click_link('New Review')
      within('#review_form') do
        fill_in 'Notes', with: 'This was hard'
        fill_in 'Rating', with: 7
        fill_in 'Work required', with: 7
        fill_in 'Difficulty', with: 7
        fill_in 'Grade', with: 87
        fill_in 'Term', with: 2
        fill_in 'Year', with: Time.zone.now.year
      end
      click_button 'Submit'
      expect(page).to have_content('Review was successfully created.')
      review = Review.last
      expect(page).to have_content(review.course.full_number)
      expect(page).to have_content('This was hard')
      click_link(review1.course.full_number)
      within('table.reviews') do
        expect(page).to have_content('This was hard')
        expect(page).to have_content("#{review.course.name} (#{review.course.full_number})")
      end

      within("tr#review_row_#{review1.id}") do
        expect(page).not_to have_content('Edit')
        expect(page).not_to have_content('Delete')
      end

      within("tr#review_row_#{review.id}") do
        click_link('Edit')
      end

      expect(page).to have_content('Editing Review')
      within('#review_form') do
        fill_in 'Notes', with: 'Easy peasy'
      end
      click_button 'Submit'
      expect(page).to have_content('Review was successfully updated.')
      expect(page).to have_content('Easy peasy')
      click_link(review1.course.full_number)
      within('table.reviews') do
        expect(page).to have_content('Easy peasy')
      end

      within("tr#review_row_#{review.id}") do
        click_link('Delete')
      end
      expect(page).to have_content('Review was successfully destroyed.')
    end
  end

  describe 'create a review, edit and destroy a different review as admin' do
    let!(:review1) { create(:review) }
    let!(:review2) { create(:review) }

    it 'allows the user to create, edit, and destroy a Review' do
      user = create(:admin)
      visit '/'
      click_link('Sign in')
      within('#new_user') do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '867-J3nny-5309!'
      end
      click_button 'Log in'
      expect(page).to have_content('Signed in successfully.')
      click_link('Courses')
      within('table.courses') do
        expect(page).to have_content(review1.course.name)
        expect(page).to have_content(review2.course.name)
        click_link(review1.course.name)
      end
      expect(page).to have_content('New Review')

      click_link('New Review')
      within('#review_form') do
        fill_in 'Notes', with: 'This was hard'
        fill_in 'Rating', with: 7
        fill_in 'Work required', with: 7
        fill_in 'Difficulty', with: 7
        fill_in 'Grade', with: 87
        fill_in 'Term', with: 2
        fill_in 'Year', with: Time.zone.now.year
      end
      click_button 'Submit'
      expect(page).to have_content('Review was successfully created.')
      review = Review.last
      expect(page).to have_content(review.course.full_number)
      expect(page).to have_content('This was hard')
      click_link(review1.course.full_number)
      within('table.reviews') do
        expect(page).to have_content('This was hard')
        expect(page).to have_content("#{review.course.name} (#{review.course.full_number})")
      end

      within("tr#review_row_#{review1.id}") do
        expect(page).to have_content('Edit')
        expect(page).to have_content('Delete')
        click_link('Edit')
      end

      expect(page).to have_content('Editing Review')
      within('#review_form') do
        fill_in 'Notes', with: 'Easy Peasy'
        fill_in 'Rating', with: nil
      end
      click_button 'Submit'
      expect(page).not_to have_content('Review was successfully updated.')
      expect(page).to have_content('2 errors prohibited this review from being saved:')
      expect(page).to have_content('Rating is not a number')

      within('#review_form') do
        fill_in 'Notes', with: 'Easy peasy'
        fill_in 'Rating', with: 8
      end
      click_button 'Submit'
      expect(page).to have_content('Review was successfully updated.')
      expect(page).to have_content('Easy peasy')
      click_link(review1.course.full_number)
      within('table.reviews') do
        expect(page).to have_content('Easy peasy')
      end

      within("tr#review_row_#{review1.id}") do
        click_link('Delete')
      end
      expect(page).to have_content('Review was successfully destroyed.')
    end
  end
end
