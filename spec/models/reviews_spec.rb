# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Review, type: :model do
  context 'validations' do
    it { should validate_presence_of(:rating) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:course_id) }
  end

  context 'associations' do
    it { should belong_to :course }
    it { should belong_to :user }
  end
end