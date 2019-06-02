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

  context 'methods' do
    it 'returns the full course number' do
      course = Course.new(name: 'Capstone', department: 'SWENG', number: '123')
      expect(course.full_number).to eq 'SWENG 123'
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
