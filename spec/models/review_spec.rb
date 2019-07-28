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
    it { should have_one(:department).through(:course) }
  end

  context 'scopes' do
    describe 'search_query' do
      it 'gets all reviews with query' do
        review1 = create(:review, notes: 'unicorns')
        review2 = create(:review, notes: 'oh no')
        review3 = create(:review, notes: 'bye')
        aggregate_failures do
          expect(Review.search_query('unicorns').length).to eq 1
          expect(Review.search_query('unicorns')).to include review1
          expect(Review.search_query('unicorns')).not_to include review2
          expect(Review.search_query('unicorns')).not_to include review3
        end
      end
    end

    describe 'sorted_by' do
      it 'gets all reviews sorted' do
        school1 = create(:school, name: 'abc')
        school2 = create(:school, name: 'xyz')
        department1 = create(:department, name: 'abc', school: school1)
        department2 = create(:department, name: 'xyz', school: school2)
        course1 = create(:course, name: 'Alphabets', department: department2)
        course2 = create(:course, name: 'Zebra', department: department1)
        review1 = create(:review,
                         notes: 'unicorns',
                         course: course2,
                         difficulty: 2,
                         rating: 10,
                         work_required: 0,
                         grade: 100,
                         experience_with_topic: false,
                         teacher: 'Zwyno')
        review2 = create(:review,
                         notes: 'oh no',
                         course: course1,
                         difficulty: 8,
                         rating: 3,
                         work_required: 20,
                         grade: 50,
                         experience_with_topic: true,
                         teacher: 'Ariel')
        review3 = create(:review,
                         notes: 'bye',
                         difficulty: 4,
                         rating: 8,
                         work_required: 25,
                         grade: 85,
                         experience_with_topic: false,
                         teacher: 'Bob')
        aggregate_failures do
          expect(Review.sorted_by('user_asc').first).to eq review1
          expect(Review.sorted_by('user_desc').first).to eq review3
          expect(Review.sorted_by('school_asc').first).to eq review1
          expect(Review.sorted_by('school_desc').first).to eq review2
          expect(Review.sorted_by('department_asc').first).to eq review1
          expect(Review.sorted_by('department_desc').first).to eq review2
          expect(Review.sorted_by('course_asc').first).to eq review2
          expect(Review.sorted_by('course_desc').first).to eq review1
          expect(Review.sorted_by('rating_asc').first).to eq review2
          expect(Review.sorted_by('rating_desc').first).to eq review1
          expect(Review.sorted_by('difficulty_asc').first).to eq review1
          expect(Review.sorted_by('difficulty_desc').first).to eq review2
          expect(Review.sorted_by('work_required_asc').first).to eq review1
          expect(Review.sorted_by('work_required_desc').first).to eq review3
          expect(Review.sorted_by('grade_asc').first).to eq review2
          expect(Review.sorted_by('grade_desc').first).to eq review1
          expect(Review.sorted_by('experience_with_topic_desc').first).to eq review2
          expect(Review.sorted_by('teacher_asc').first).to eq review2
          expect(Review.sorted_by('teacher_desc').first).to eq review1
          expect { Review.sorted_by('oh_no') }.to raise_error(ArgumentError, 'Invalid sort option: "oh_no"')
        end
      end
    end

    describe 'with_course_id' do
      it 'gets all reviews with query in review' do
        course = create(:course)
        review1 = create(:review)
        review2 = create(:review, course: course)
        review3 = create(:review, course: course)
        aggregate_failures do
          expect(Review.with_course_id(course.id).length).to eq 2
          expect(Review.with_course_id(course.id)).not_to include review1
          expect(Review.with_course_id(course.id)).to include review2
          expect(Review.with_course_id(course.id)).to include review3
        end
      end
    end

    describe 'with_school_id' do
      it 'gets all reviews with query in review' do
        school = create(:school)
        department = create(:department, school: school)
        course = create(:course, department: department)
        review1 = create(:review, course: course)
        review2 = create(:review)
        review3 = create(:review, course: course)
        aggregate_failures do
          expect(Review.with_school_id(school.id).length).to eq 2
          expect(Review.with_school_id(school.id)).not_to include review2
          expect(Review.with_school_id(school.id)).to include review1
          expect(Review.with_school_id(school.id)).to include review3
        end
      end
    end

    describe 'with_rating_gte' do
      it 'gets all reviews with query in review' do
        review1 = create(:review, rating: 10)
        review2 = create(:review, rating: 2)
        review3 = create(:review, rating: 5)
        aggregate_failures do
          expect(Review.with_rating_gte(3).length).to eq 2
          expect(Review.with_rating_gte(3)).not_to include review2
          expect(Review.with_rating_gte(3)).to include review1
          expect(Review.with_rating_gte(3)).to include review3
        end
      end
    end

    describe 'with_difficulty_lte' do
      it 'gets all reviews with query in review' do
        review1 = create(:review, difficulty: 4)
        review2 = create(:review, difficulty: 10)
        review3 = create(:review, difficulty: 2)
        aggregate_failures do
          expect(Review.with_difficulty_lte(5).length).to eq 2
          expect(Review.with_difficulty_lte(5)).not_to include review2
          expect(Review.with_difficulty_lte(5)).to include review1
          expect(Review.with_difficulty_lte(5)).to include review3
        end
      end
    end

    describe 'with_work_required_lte' do
      it 'gets all reviews with query in review' do
        review1 = create(:review, work_required: 10)
        review2 = create(:review, work_required: 5)
        review3 = create(:review, work_required: 15)
        aggregate_failures do
          expect(Review.with_work_required_lte(10).length).to eq 2
          expect(Review.with_work_required_lte(10)).to include review1
          expect(Review.with_work_required_lte(10)).to include review2
          expect(Review.with_work_required_lte(10)).not_to include review3
        end
      end
    end
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

    describe '#options_for_sorted_by' do
      it 'returns all fields that can be sorted' do
        expected_result = [
                            ['User ID (lowest first)', 'user_id_asc'],
                            ['Rating (lowest first)', 'rating_asc'],
                            ['Rating (highest first)', 'rating_desc'],
                            ['Difficulty (lowest first)', 'difficulty_asc'],
                            ['Difficulty (highest first)', 'difficulty_desc'],
                            ['Work Required (lowest first)', 'work_required_asc'],
                            ['Work Required (highest first)', 'work_required_desc'],
                            ['Department (a-z)', 'department_name_asc'],
                            ['Course (a-z)', 'course_name_asc'],
                            ['School (a-z)', 'school_name_asc'],
                            ['Teacher (a-z)', 'teacher_name_asc']
                          ]
        expect(Review.options_for_sorted_by).to eq expected_result
      end
    end
  end
end

# == Schema Information
#
# Table name: reviews
#
#  id                    :bigint           not null, primary key
#  difficulty            :integer
#  experience_with_topic :boolean
#  grade                 :integer
#  notes                 :string
#  rating                :integer
#  teacher               :string
#  term                  :integer
#  work_required         :integer
#  year                  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  course_id             :bigint
#  user_id               :bigint
#
# Indexes
#
#  index_reviews_on_course_id  (course_id)
#  index_reviews_on_user_id    (user_id)
#
