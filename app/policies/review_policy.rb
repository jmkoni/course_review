class ReviewPolicy < ApplicationPolicy
  attr_reader :user, :review

  def initialize(user, review)
    @user = user
    @review = review
  end

  def update?
    user.admin? || review.user == user
  end

  def create?
    !(user.blank? || user.deactivated)
  end

  def destroy?
    user.admin? || review.user == user
  end
end