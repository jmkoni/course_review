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
        aggregate_failures do
          expect(Course.sorted_by('department_asc').first).to eq course1
          expect(Course.sorted_by('department_desc').first).to eq course2
          expect(Course.sorted_by('school_asc').first).to eq course2
          expect(Course.sorted_by('school_desc').first).to eq course1
          expect(Course.sorted_by('name_asc').first).to eq course1
          expect(Course.sorted_by('name_desc').first).to eq course2
          expect(Course.sorted_by('number_asc').first).to eq course3
          expect(Course.sorted_by('number_desc').first).to eq course1
          expect { Course.sorted_by('oh_no') }.to raise_error(ArgumentError, 'Invalid sort option: "oh_no"')
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
        ['School (z-a)', 'school_name_desc']
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
