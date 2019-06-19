# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course, type: :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive.scoped_to(:school_id) }
    it { should validate_presence_of(:department) }
    it { should validate_presence_of(:number) }
    it { should validate_uniqueness_of(:number).case_insensitive.scoped_to(:department) }
  end

  context 'associations' do
    it { should belong_to :school }
  end

  context 'scopes' do
    describe 'search_query' do
      it 'gets all courses with query' do
        course1 = create(:course, name: 'unicorns')
        course2 = create(:course, name: 'oh no')
        course3 = create(:course, name: 'bye')
        aggregate_failures do
          expect(Course.search_query('unicorns').length).to eq 1
          expect(Course.search_query('unicorns')).to include course1
          expect(Course.search_query('unicorns')).not_to include course2
          expect(Course.search_query('unicorns')).not_to include course3
        end
      end
    end

    describe 'sorted_by' do
      it 'gets all courses sorted' do
        school1 = create(:school, name: 'abc')
        school2 = create(:school, name: 'xyz')
        course1 = create(:course, department: 'Alphabets', name: 'ABC', number: '3000', school: school2)
        course2 = create(:course, department: 'Zebra', name: 'Zebras', number: '2000', school: school1)
        course3 = create(:course, department: 'Cows', name: 'Bovine', number: '1001')
        review1 = create(:review, course: course1, work_required: 1, difficulty: 5, rating: 10)
        review2 = create(:review, course: course2, work_required: 5, difficulty: 10, rating: 1)
        review3 = create(:review, course: course3, work_required: 10, difficulty: 1, rating: 5)
        aggregate_failures do
          expect(Course.with_averages.sorted_by('department_asc').first).to eq course1
          expect(Course.with_averages.sorted_by('department_desc').first).to eq course2
          expect(Course.with_averages.sorted_by('school_asc').first).to eq course2
          expect(Course.with_averages.sorted_by('school_desc').first).to eq course1
          expect(Course.with_averages.sorted_by('name_asc').first).to eq course1
          expect(Course.with_averages.sorted_by('name_desc').first).to eq course2
          expect(Course.with_averages.sorted_by('number_asc').first).to eq course3
          expect(Course.with_averages.sorted_by('number_desc').first).to eq course1
          expect(Course.with_averages.sorted_by('avg_work_desc').first).to eq course3
          expect(Course.with_averages.sorted_by('avg_work_asc').first).to eq course1
          expect(Course.with_averages.sorted_by('avg_rating_desc').first).to eq course1
          expect(Course.with_averages.sorted_by('avg_rating_asc').first).to eq course2
          expect(Course.with_averages.sorted_by('avg_difficulty_desc').first).to eq course2
          expect(Course.with_averages.sorted_by('avg_difficulty_asc').first).to eq course3
          expect { Course.with_averages.sorted_by('oh_no') }.to raise_error(ArgumentError, 'Invalid sort option: "oh_no"')
        end
      end
    end

    describe 'with_school_id' do
      it 'gets all reviews with query in review' do
        school = create(:school)
        course1 = create(:course, school: school)
        course2 = create(:course)
        course3 = create(:course)
        aggregate_failures do
          expect(Course.with_school_id(school.id).length).to eq 1
          expect(Course.with_school_id(school.id)).to include course1
          expect(Course.with_school_id(school.id)).not_to include course2
          expect(Course.with_school_id(school.id)).not_to include course3
        end
      end
    end

    describe 'with_avg_rating_gte' do
      it 'gets all reviews with query in review' do
        course1 = create(:course)
        course2 = create(:course)
        course3 = create(:course)
        review1 = create(:review, rating: 10, course: course1)
        review2 = create(:review, rating: 2, course: course2)
        review3 = create(:review, rating: 5, course: course3)
        aggregate_failures do
          expect(Course.with_averages.with_avg_rating_gte(3).length).to eq 2
          expect(Course.with_averages.with_avg_rating_gte(3)).not_to include course2
          expect(Course.with_averages.with_avg_rating_gte(3)).to include course1
          expect(Course.with_averages.with_avg_rating_gte(3)).to include course3
        end
      end
    end

    describe 'with_avg_difficulty_lte' do
      it 'gets all reviews with query in review' do
        course1 = create(:course)
        course2 = create(:course)
        course3 = create(:course)
        review1 = create(:review, difficulty: 4, course: course1)
        review2 = create(:review, difficulty: 10, course: course2)
        review3 = create(:review, difficulty: 2, course: course3)
        aggregate_failures do
          expect(Course.with_averages.with_avg_difficulty_lte(5).length).to eq 2
          expect(Course.with_averages.with_avg_difficulty_lte(5)).not_to include course2
          expect(Course.with_averages.with_avg_difficulty_lte(5)).to include course1
          expect(Course.with_averages.with_avg_difficulty_lte(5)).to include course3
        end
      end
    end

    describe 'with_avg_work_lte' do
      it 'gets all reviews with query in review' do
        course1 = create(:course)
        course2 = create(:course)
        course3 = create(:course)
        review1 = create(:review, work_required: 10, course: course1)
        review2 = create(:review, work_required: 5, course: course2)
        review3 = create(:review, work_required: 15, course: course3)
        aggregate_failures do
          expect(Course.with_averages.with_avg_work_lte(10).length).to eq 2
          expect(Course.with_averages.with_avg_work_lte(10)).to include course1
          expect(Course.with_averages.with_avg_work_lte(10)).to include course2
          expect(Course.with_averages.with_avg_work_lte(10)).not_to include course3
        end
      end
    end
  end

  context 'methods' do
    it 'returns the full course number' do
      course = Course.new(name: 'Capstone', department: 'SWENG', number: '123')
      expect(course.full_number).to eq 'SWENG 123'
    end

    it 'returns options for sorted by' do
      expected_options = [
        ['Name (a-z)', 'name_asc'],
        ['Name (z-a)', 'name_desc'],
        ['Number (lowest first)', 'number_asc'],
        ['Number (highest first)', 'number_desc'],
        ['Department (a-z)', 'department_asc'],
        ['Department (z-a)', 'department_desc'],
        ['School (a-z)', 'school_name_asc'],
        ['School (z-a)', 'school_name_desc'],
        ['Average Rating (highest first)', 'avg_rating_desc'],
        ['Average Work Required (lowest first)', 'avg_work_asc'],
        ['Average Difficulty (lowest first)', 'avg_difficulty_asc']
      ]
      expect(Course.options_for_sorted_by).to eq expected_options
    end
  end
end

# == Schema Information
#
# Table name: courses
#
#  id         :bigint           not null, primary key
#  department :string
#  name       :string
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint
#
# Indexes
#
#  index_courses_on_school_id  (school_id)
#
