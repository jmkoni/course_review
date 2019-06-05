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
    it { should have_one(:school).through(:course) }
  end

  context 'methods' do
    describe '#letter_grade' do
      it 'returns an A' do
        review = create(:review, grade: 90)
        expect(review.letter_grade).to eq 'A'
      end

      it 'returns an B' do
        review = create(:review, grade: 89)
        expect(review.letter_grade).to eq 'B'
      end

      it 'returns an C' do
        review = create(:review, grade: 70)
        expect(review.letter_grade).to eq 'C'
      end

      it 'returns an D' do
        review = create(:review, grade: 69)
        expect(review.letter_grade).to eq 'D'
      end

      it 'returns an F' do
        review = create(:review, grade: 2)
        expect(review.letter_grade).to eq 'F'
      end

      it 'returns Error if not expected' do
        review = create(:review, grade: -2)
        expect(review.letter_grade).to eq 'Error'
      end
    end

    describe '#display_grade' do
      it 'displays the percentage and letter grade' do
        review = create(:review, grade: 90)
        expect(review.display_grade).to eq '90% (A)'
      end
    end
  end
end
