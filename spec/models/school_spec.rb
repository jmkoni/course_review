# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
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
