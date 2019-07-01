# frozen_string_literal: true

class Department < ApplicationRecord
  validates :name, presence: true
  validates :short_name, presence: true, uniqueness: { case_sensitive: false, scope: :school_id }
  belongs_to :school
  has_many :courses, dependent: :destroy

  filterrific(
    default_filter_params: { sorted_by: 'name_desc' },
    available_filters: %i[
      sorted_by
      search_query
      with_school_id
      with_avg_rating_gte
      with_avg_difficulty_lte
      with_avg_work_lte
      with_avg_grade_gte
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
    num_or_conditions = 3
    joins(:school).where(
      terms.map do
        or_clauses = [
          'LOWER(departments.name) LIKE ?',
          'LOWER(departments.short_name) LIKE ?',
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
    when /^short_name_/
      order(Arel.sql("LOWER(departments.short_name) #{direction}"))
    when /^name_/
      order(Arel.sql("LOWER(departments.name) #{direction}"))
    when /^school_/
      order(Arel.sql("LOWER(schools.name) #{direction}")).includes(:school).references(:school)
    when /^avg_rating_/
      order(Arel.sql("avg_rating #{direction}"))
    when /^avg_difficulty_/
      order(Arel.sql("avg_difficulty #{direction}"))
    when /^avg_work_/
      order(Arel.sql("avg_work #{direction}"))
    when /^avg_grade_/
      order(Arel.sql("avg_grade #{direction}"))
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_school_id, ->(school_ids) {
    where('school_id in (?)', [*school_ids])
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

  scope :with_avg_grade_gte, ->(ref_num) {
    having('avg(reviews.grade) >= ?', ref_num)
  }

  scope :with_averages, -> {
    preload(:school, courses: :reviews)
      .select('departments.*,
            avg(reviews.rating) as avg_rating,
            avg(reviews.difficulty) as avg_difficulty,
            avg(reviews.work_required) as avg_work,
            avg(reviews.grade) as avg_grade')
      .left_joins(:school, courses: :reviews)
      .group('departments.id, schools.id')
  }

  def self.options_for_select
    departments = Department.arel_table
    order(departments[:name].lower).pluck(:name, :id)
  end

  def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Name (z-a)', 'name_desc'],
      ['Short Name (a-z)', 'short_name_asc'],
      ['Short Name (z-a)', 'short_name_desc'],
      ['School (a-z)', 'school_name_asc'],
      ['School (z-a)', 'school_name_desc'],
      ['Average Rating (highest first)', 'avg_rating_desc'],
      ['Average Work Required (lowest first)', 'avg_work_asc'],
      ['Average Difficulty (lowest first)', 'avg_difficulty_asc'],
      ['Average Grade (highest first)', 'avg_grade_desc']
    ]
  end
end

# == Schema Information
#
# Table name: departments
#
#  id         :bigint           not null, primary key
#  name       :string
#  short_name :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint
#
# Indexes
#
#  index_departments_on_school_id  (school_id)
#
