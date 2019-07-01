# typed: false
# frozen_string_literal: true

class Review < ApplicationRecord
  validates :rating, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :course_id }
  validates :grade, numericality: { in: 0..100 }
  validates :rating, numericality: { in: 0..10 }
  validates :difficulty, numericality: { in: 0..10 }
  validates :year, numericality: { in: 1990..Time.zone.now.year }
  validates :term, numericality: { in: 1..10 }
  validates :work_required, numericality: { in: 0..100 }

  belongs_to :course
  belongs_to :user
  has_one :department, through: :course

  filterrific(
    default_filter_params: { sorted_by: 'rating_desc' },
    available_filters: %i[
      sorted_by
      search_query
      with_course_id
      with_school_id
      with_rating_gte
      with_difficulty_lte
      with_work_required_lte
    ]
  )

  scope :search_query, ->(query) {
    return nil if query.blank?

    # condition query, parse into individual keywords
    terms = query.to_s.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map do |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    end
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 4
    joins(course: :department).where(
      terms.map do
        or_clauses = [
          'LOWER(reviews.notes) LIKE ?',
          'LOWER(departments.name) LIKE ?',
          'LOWER(courses.name) LIKE ?',
          'LOWER(courses.number) LIKE ?'
        ].join(' OR ')
        "(#{or_clauses})"
      end.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, ->(sort_option) {
    # extract the sort direction from the param value.
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^user_/
      order(Arel.sql("reviews.user_id #{direction}"))
    when /^course_/
      order(Arel.sql("LOWER(courses.name) #{direction}")).includes(:course).references(:course)
    when /^department_/
      order(Arel.sql("LOWER(departments.name) #{direction}")).includes(course: [:department]).references(:course)
    when /^school_/
      order(Arel.sql("LOWER(schools.name) #{direction}")).includes(course: { department: :school }).references(:course)
    when /^difficulty_/
      order(Arel.sql("reviews.difficulty #{direction}"))
    when /^rating_/
      order(Arel.sql("reviews.rating #{direction}"))
    when /^work_required_/
      order(Arel.sql("reviews.work_required #{direction}"))
    when /^experience_with_topic_/
      order(Arel.sql("reviews.experience_with_topic #{direction}"))
    when /^grade_/
      order(Arel.sql("reviews.grade #{direction}"))
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_course_id, ->(course_ids) {
    where(course_id: [*course_ids])
  }

  scope :with_school_id, ->(school_ids) {
    joins(course: :department).where('departments.school_id = ?', [*school_ids])
  }

  scope :with_rating_gte, ->(ref_num) {
    where('reviews.rating >= ?', ref_num)
  }

  scope :with_difficulty_lte, ->(ref_num) {
    where('reviews.difficulty <= ?', ref_num)
  }

  scope :with_work_required_lte, ->(ref_num) {
    where('reviews.work_required <= ?', ref_num)
  }

  def self.options_for_sorted_by
    [
      ['User ID (lowest first)', 'user_id_asc'],
      ['Rating (lowest first)', 'rating_asc'],
      ['Rating (highest first)', 'rating_desc'],
      ['Difficulty (lowest first)', 'difficulty_asc'],
      ['Difficulty (highest first)', 'difficulty_desc'],
      ['Work Required (lowest first)', 'work_required_asc'],
      ['Work Required (highest first)', 'work_required_desc'],
      ['Course (a-z)', 'course_name_asc'],
      ['School (a-z)', 'school_name_asc']
    ]
  end

  def letter_grade
    case grade
    when 90..100
      'A'
    when 80..90
      'B'
    when 70..80
      'C'
    when 60..70
      'D'
    when 0..60
      'F'
    else
      'Error'
    end
  end

  def display_grade
    "#{grade}% (#{letter_grade})"
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
