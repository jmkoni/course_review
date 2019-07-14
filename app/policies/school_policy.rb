class SchoolPolicy < ApplicationPolicy
  attr_reader :user, :school

  def initialize(user, school)
    @user = user
    @school = school
  end

end