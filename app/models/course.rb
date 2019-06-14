# frozen_string_literal: true

class Course < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :school_id }
  validates :department, presence: true
  validates :number, presence: true, uniqueness: { case_sensitive: false, scope: :department }
  belongs_to :school
  has_many :reviews, dependent: :destroy

  def full_number
    "#{department} #{number}"
  end

  def self.options_for_select
    courses = Course.arel_table
    order(courses[:name].lower).pluck(:name, :id)
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
