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
        aggregate_failures do
          expect(School.sorted_by('name_asc').first).to eq school1
          expect(School.sorted_by('name_desc').first).to eq school2
          expect(School.sorted_by('short_name_asc').first).to eq school1
          expect(School.sorted_by('short_name_desc').first).to eq school2
          expect { School.sorted_by('oh_no') }.to raise_error(ArgumentError, 'Invalid sort option: "oh_no"')
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
        ['Short Name (z-a)', 'short_name_desc']
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
