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
    # it { should have_many :courses }
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
