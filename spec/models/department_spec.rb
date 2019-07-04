# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Department, type: :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:short_name) }
    it { should validate_uniqueness_of(:short_name).case_insensitive.scoped_to(:school_id) }
  end

  context 'associations' do
    it { should belong_to :school }
  end

  context 'scopes' do
    describe 'search_query' do
      it 'gets all departments with query' do
        department1 = create(:department, name: 'unicorns')
        department2 = create(:department, name: 'oh no')
        department3 = create(:department, name: 'bye')
        aggregate_failures do
          expect(Department.search_query('unicorns').length).to eq 1
          expect(Department.search_query('unicorns')).to include department1
          expect(Department.search_query('unicorns')).not_to include department2
          expect(Department.search_query('unicorns')).not_to include department3
        end
      end
    end

    describe 'sorted_by' do
      it 'gets all departments sorted' do
        school1 = create(:school, name: 'abc')
        school2 = create(:school, name: 'xyz')
        department1 = create(:department, name: 'Alphabets', short_name: 'ABC', school: school2)
        department2 = create(:department, name: 'Zebra', short_name: 'ZEB', school: school1)
        department3 = create(:department, name: 'Cows', short_name: 'COW')
        course1 = create(:course, department: department1, name: 'ABC', number: '3000')
        course2 = create(:course, department: department2, name: 'Zebras', number: '2000')
        course3 = create(:course, department: department3, name: 'Bovine', number: '1001')
        review1 = create(:review, course: course1, work_required: 1, difficulty: 5, rating: 10, grade: 100)
        review2 = create(:review, course: course2, work_required: 5, difficulty: 10, rating: 1, grade: 46)
        review3 = create(:review, course: course3, work_required: 10, difficulty: 1, rating: 5, grade: 72)
        aggregate_failures do
          expect(Department.with_averages.sorted_by('short_name_asc').first).to eq department1
          expect(Department.with_averages.sorted_by('short_name_desc').first).to eq department2
          expect(Department.with_averages.sorted_by('school_asc').first).to eq department2
          expect(Department.with_averages.sorted_by('school_desc').first).to eq department1
          expect(Department.with_averages.sorted_by('department_asc').first).to eq department1
          expect(Department.with_averages.sorted_by('department_desc').first).to eq department2
          expect(Department.with_averages.sorted_by('avg_work_desc').first).to eq department3
          expect(Department.with_averages.sorted_by('avg_work_asc').first).to eq department1
          expect(Department.with_averages.sorted_by('avg_rating_desc').first).to eq department1
          expect(Department.with_averages.sorted_by('avg_rating_asc').first).to eq department2
          expect(Department.with_averages.sorted_by('avg_grade_desc').first).to eq department1
          expect(Department.with_averages.sorted_by('avg_grade_asc').first).to eq department2
          expect(Department.with_averages.sorted_by('avg_difficulty_desc').first).to eq department2
          expect(Department.with_averages.sorted_by('avg_difficulty_asc').first).to eq department3
          expect { Department.with_averages.sorted_by('oh_no') }.to raise_error(ArgumentError, 'Invalid sort option: "oh_no"')
        end
      end
    end

    describe 'with_school_id' do
      it 'gets all reviews with query in review' do
        school = create(:school)
        department1 = create(:department, school: school)
        department2 = create(:department)
        department3 = create(:department)
        aggregate_failures do
          expect(Department.with_school_id(school.id).length).to eq 1
          expect(Department.with_school_id(school.id)).to include department1
          expect(Department.with_school_id(school.id)).not_to include department2
          expect(Department.with_school_id(school.id)).not_to include department3
        end
      end
    end

    describe 'with_avg_rating_gte' do
      it 'gets all reviews with query in review' do
        department1 = create(:department)
        department2 = create(:department)
        department3 = create(:department)
        course1 = create(:course, department: department1)
        course2 = create(:course, department: department2)
        course3 = create(:course, department: department3)
        review1 = create(:review, rating: 10, course: course1)
        review2 = create(:review, rating: 2, course: course2)
        review3 = create(:review, rating: 5, course: course3)
        aggregate_failures do
          expect(Department.with_averages.with_avg_rating_gte(3).length).to eq 2
          expect(Department.with_averages.with_avg_rating_gte(3)).not_to include department2
          expect(Department.with_averages.with_avg_rating_gte(3)).to include department1
          expect(Department.with_averages.with_avg_rating_gte(3)).to include department3
        end
      end
    end

    describe 'with_avg_grade_gte' do
      it 'gets all reviews with query in review' do
        department1 = create(:department)
        department2 = create(:department)
        department3 = create(:department)
        course1 = create(:course, department: department1)
        course2 = create(:course, department: department2)
        course3 = create(:course, department: department3)
        review1 = create(:review, grade: 100, course: course1)
        review2 = create(:review, grade: 23, course: course2)
        review3 = create(:review, grade: 78, course: course3)
        aggregate_failures do
          expect(Department.with_averages.with_avg_grade_gte(30).length).to eq 2
          expect(Department.with_averages.with_avg_grade_gte(30)).not_to include department2
          expect(Department.with_averages.with_avg_grade_gte(30)).to include department1
          expect(Department.with_averages.with_avg_grade_gte(30)).to include department3
        end
      end
    end

    describe 'with_avg_difficulty_lte' do
      it 'gets all reviews with query in review' do
        department1 = create(:department)
        department2 = create(:department)
        department3 = create(:department)
        course1 = create(:course, department: department1)
        course2 = create(:course, department: department2)
        course3 = create(:course, department: department3)
        review1 = create(:review, difficulty: 4, course: course1)
        review2 = create(:review, difficulty: 10, course: course2)
        review3 = create(:review, difficulty: 2, course: course3)
        aggregate_failures do
          expect(Department.with_averages.with_avg_difficulty_lte(5).length).to eq 2
          expect(Department.with_averages.with_avg_difficulty_lte(5)).not_to include department2
          expect(Department.with_averages.with_avg_difficulty_lte(5)).to include department1
          expect(Department.with_averages.with_avg_difficulty_lte(5)).to include department3
        end
      end
    end

    describe 'with_avg_work_lte' do
      it 'gets all reviews with query in review' do
        department1 = create(:department)
        department2 = create(:department)
        department3 = create(:department)
        course1 = create(:course, department: department1)
        course2 = create(:course, department: department2)
        course3 = create(:course, department: department3)
        review1 = create(:review, work_required: 10, course: course1)
        review2 = create(:review, work_required: 5, course: course2)
        review3 = create(:review, work_required: 15, course: course3)
        aggregate_failures do
          expect(Department.with_averages.with_avg_work_lte(10).length).to eq 2
          expect(Department.with_averages.with_avg_work_lte(10)).to include department1
          expect(Department.with_averages.with_avg_work_lte(10)).to include department2
          expect(Department.with_averages.with_avg_work_lte(10)).not_to include department3
        end
      end
    end
  end

  context 'methods' do
    it 'returns options for sorted by' do
      expected_options = [
        ['Department Name (a-z)', 'department_asc'],
        ['Department Name (z-a)', 'department_desc'],
        ['Short Name (a-z)', 'short_name_asc'],
        ['Short Name (z-a)', 'short_name_desc'],
        ['School Name (a-z)', 'school_name_asc'],
        ['School Name (z-a)', 'school_name_desc'],
        ['Average Rating (highest first)', 'avg_rating_desc'],
        ['Average Work Required (lowest first)', 'avg_work_asc'],
        ['Average Difficulty (lowest first)', 'avg_difficulty_asc'],
        ['Average Grade (highest first)', 'avg_grade_desc']
      ]
      expect(Department.options_for_sorted_by).to eq expected_options
    end
  end
end

# == Schema Information
#
# Table name: departments
#
#  id         :bigint           not null, primary key
#  name       :string
#  short_name :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint
#
# Indexes
#
#  index_departments_on_school_id  (school_id)
#
