class UserPolicy < ApplicationPolicy
  attr_reader :user, :updated_user

  def initialize(user, updated_user)
    @user = user
    @updated_user = updated_user
  end

  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def activate?
    user.admin?
  end

  def deactivate?
    user.admin?
  end

  def promote?
    user.admin?
  end

  def demote?
    user.admin?
  end

end