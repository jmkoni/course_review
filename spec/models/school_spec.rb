# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe School, type: :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_presence_of(:short_name) }
    it { should validate_uniqueness_of(:short_name).case_insensitive }
  end

  context 'associations' do
    it { should have_many :courses }
  end

  context 'scopes' do
    describe 'search_query' do
      it 'gets all schools with query' do
        school1 = create(:school, name: 'unicorns')
        school2 = create(:school, name: 'oh no')
        school3 = create(:school, name: 'bye')
        aggregate_failures do
          expect(School.search_query('unicorns').length).to eq 1
          expect(School.search_query('unicorns')).to include school1
          expect(School.search_query('unicorns')).not_to include school2
          expect(School.search_query('unicorns')).not_to include school3
        end
      end
    end

    describe 'sorted_by' do
      it 'gets all courses sorted' do
        school1 = create(:school, name: 'Alphabets', short_name: 'abc')
        school2 = create(:school, name: 'Zebra', short_name: 'xyz')
        school3 = create(:school, name: 'Cows', short_name: 'Bovine')
        course1 = create(:course, school: school1)
        course2 = create(:course, school: school2)
        course3 = create(:course, school: school3)
        review1 = create(:review, course: course1, work_required: 1, difficulty: 5, rating: 10, grade: 100)
        review2 = create(:review, course: course2, work_required: 5, difficulty: 10, rating: 1, grade: 50)
        review3 = create(:review, course: course3, work_required: 10, difficulty: 1, rating: 5, grade: 70)
        aggregate_failures do
          expect(School.sorted_by('name_asc').first).to eq school1
          expect(School.sorted_by('name_desc').first).to eq school2
          expect(School.sorted_by('short_name_asc').first).to eq school1
          expect(School.sorted_by('short_name_desc').first).to eq school2
          expect(School.with_averages.sorted_by('avg_work_desc').first).to eq school3
          expect(School.with_averages.sorted_by('avg_work_asc').first).to eq school1
          expect(School.with_averages.sorted_by('avg_rating_desc').first).to eq school1
          expect(School.with_averages.sorted_by('avg_rating_asc').first).to eq school2
          expect(School.with_averages.sorted_by('avg_grade_desc').first).to eq school1
          expect(School.with_averages.sorted_by('avg_grade_asc').first).to eq school2
          expect(School.with_averages.sorted_by('avg_difficulty_desc').first).to eq school2
          expect(School.with_averages.sorted_by('avg_difficulty_asc').first).to eq school3
          expect { School.sorted_by('oh_no') }.to raise_error(ArgumentError, 'Invalid sort option: "oh_no"')
        end
      end
    end

    describe 'with_avg_rating_gte' do
      it 'gets all reviews with query in review' do
        school1 = create(:school)
        school2 = create(:school)
        school3 = create(:school)
        course1 = create(:course, school: school1)
        course2 = create(:course, school: school2)
        course3 = create(:course, school: school3)
        review1 = create(:review, rating: 10, course: course1)
        review2 = create(:review, rating: 2, course: course2)
        review3 = create(:review, rating: 5, course: course3)
        aggregate_failures do
          expect(School.with_averages.with_avg_rating_gte(3).length).to eq 2
          expect(School.with_averages.with_avg_rating_gte(3)).not_to include school2
          expect(School.with_averages.with_avg_rating_gte(3)).to include school1
          expect(School.with_averages.with_avg_rating_gte(3)).to include school3
        end
      end
    end

    describe 'with_avg_grade_gte' do
      it 'gets all reviews with query in review' do
        school1 = create(:school)
        school2 = create(:school)
        school3 = create(:school)
        course1 = create(:course, school: school1)
        course2 = create(:course, school: school2)
        course3 = create(:course, school: school3)
        review1 = create(:review, grade: 100, course: course1)
        review2 = create(:review, grade: 20, course: course2)
        review3 = create(:review, grade: 60, course: course3)
        aggregate_failures do
          expect(School.with_averages.with_avg_grade_gte(30).length).to eq 2
          expect(School.with_averages.with_avg_grade_gte(30)).not_to include school2
          expect(School.with_averages.with_avg_grade_gte(30)).to include school1
          expect(School.with_averages.with_avg_grade_gte(30)).to include school3
        end
      end
    end

    describe 'with_avg_difficulty_lte' do
      it 'gets all reviews with query in review' do
        school1 = create(:school)
        school2 = create(:school)
        school3 = create(:school)
        course1 = create(:course, school: school1)
        course2 = create(:course, school: school2)
        course3 = create(:course, school: school3)
        review1 = create(:review, difficulty: 4, course: course1)
        review2 = create(:review, difficulty: 10, course: course2)
        review3 = create(:review, difficulty: 2, course: course3)
        aggregate_failures do
          expect(School.with_averages.with_avg_difficulty_lte(5).length).to eq 2
          expect(School.with_averages.with_avg_difficulty_lte(5)).not_to include school2
          expect(School.with_averages.with_avg_difficulty_lte(5)).to include school1
          expect(School.with_averages.with_avg_difficulty_lte(5)).to include school3
        end
      end
    end

    describe 'with_avg_work_lte' do
      it 'gets all reviews with query in review' do
        school1 = create(:school)
        school2 = create(:school)
        school3 = create(:school)
        course1 = create(:course, school: school1)
        course2 = create(:course, school: school2)
        course3 = create(:course, school: school3)
        review1 = create(:review, work_required: 10, course: course1)
        review2 = create(:review, work_required: 5, course: course2)
        review3 = create(:review, work_required: 15, course: course3)
        aggregate_failures do
          expect(School.with_averages.with_avg_work_lte(10).length).to eq 2
          expect(School.with_averages.with_avg_work_lte(10)).to include school1
          expect(School.with_averages.with_avg_work_lte(10)).to include school2
          expect(School.with_averages.with_avg_work_lte(10)).not_to include school3
        end
      end
    end
  end
  context 'methods' do
    it 'returns options for sorted by' do
      expected_options = [
        ['Name (a-z)', 'name_asc'],
        ['Name (z-a)', 'name_desc'],
        ['Short Name (a-z)', 'short_name_asc'],
        ['Short Name (z-a)', 'short_name_desc'],
        ['Average Rating (highest first)', 'avg_rating_desc'],
        ['Average Work Required (lowest first)', 'avg_work_asc'],
        ['Average Difficulty (lowest first)', 'avg_difficulty_asc'],
        ['Average Grade (highest first)', 'avg_grade_desc']
      ]
      expect(School.options_for_sorted_by).to eq expected_options
    end
  end
end

# == Schema Information
#
# Table name: schools
#
#  id         :bigint           not null, primary key
#  name       :string
#  short_name :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
