# frozen_string_literal: true

class Course < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :school_id }
  validates :department, presence: true
  validates :number, presence: true, uniqueness: { case_sensitive: false, scope: :department }
  belongs_to :school
  has_many :reviews, dependent: :destroy

  filterrific(
    default_filter_params: { sorted_by: 'department_desc' },
    available_filters: %i[
      sorted_by
      search_query
      with_school_id
      with_avg_rating_gte
      with_avg_difficulty_lte
      with_avg_work_lte
    ]
  )

  scope :search_query, ->(query) {
    return nil if query.blank?

    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map do |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    end
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 4
    joins(:school).where(
      terms.map do
        or_clauses = [
          'LOWER(courses.name) LIKE ?',
          'LOWER(courses.department) LIKE ?',
          'LOWER(courses.number) LIKE ?',
          'LOWER(schools.name) LIKE ?'
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
    when /^department_/
      order(Arel.sql("LOWER(courses.department) #{direction}"))
    when /^name_/
      order(Arel.sql("LOWER(courses.name) #{direction}"))
    when /^number_/
      order(Arel.sql("LOWER(courses.number) #{direction}"))
    when /^school_/
      order(Arel.sql("LOWER(schools.name) #{direction}")).includes(:school).references(:school)
    when /^avg_rating_/
      order(Arel.sql("avg_rating #{direction}"))
    when /^avg_difficulty_/
      order(Arel.sql("avg_difficulty #{direction}"))
    when /^avg_work_/
      order(Arel.sql("avg_work #{direction}"))
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_school_id, ->(school_ids) {
    where(school_id: [*school_ids])
  }

  scope :with_avg_rating_gte, ->(ref_num) {
    having('avg(reviews.rating) >= ?', ref_num)
  }

  scope :with_avg_difficulty_lte, ->(ref_num) {
    having('avg(reviews.difficulty) <= ?', ref_num)
  }

  scope :with_avg_work_lte, ->(ref_num) {
    having('avg(reviews.work_required) <= ?', ref_num)
  }

  scope :with_averages, -> {
    select('courses.*,
            avg(reviews.rating) as avg_rating,
            avg(reviews.difficulty) as avg_difficulty,
            avg(reviews.work_required) as avg_work')
      .left_joins(:reviews, :school)
      .group('courses.id, schools.id')
  }
  def full_number
    "#{department} #{number}"
  end

  def self.options_for_select
    courses = Course.arel_table
    order(courses[:name].lower).pluck(:name, :id)
  end

  def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Name (z-a)', 'name_desc'],
      ['Number (lowest first)', 'number_asc'],
      ['Number (highest first)', 'number_desc'],
      ['Department (a-z)', 'department_asc'],
      ['Department (z-a)', 'department_desc'],
      ['School (a-z)', 'school_name_asc'],
      ['School (z-a)', 'school_name_desc'],
      ['Average Rating (highest first)', 'avg_rating_desc'],
      ['Average Work Required (lowest first)', 'avg_work_asc'],
      ['Average Difficulty (lowest first)', 'avg_difficulty_asc']
    ]
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
