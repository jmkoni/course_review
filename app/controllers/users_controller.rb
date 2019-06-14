# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[promote demote deactivate reactivate]
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    (@filterrific = initialize_filterrific(
      User.all,
      params[:filterrific],
      select_options: {
        sorted_by: User.options_for_sorted_by
      }
    )) || return
    @users = @filterrific.find.page(params[:page])
  end

  # def edit; end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  # def update
  #   respond_to do |format|
  #     if @user.update(user_params)
  #       format.html { redirect_to users_url, notice: 'User was successfully updated.' }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PUT /users/1/deactivate
  def deactivate
    @user.update(deactivated: true)
    redirect_to users_url, notice: "#{@user.email} was successfully deactivated."
  end

  # PUT /users/1/reactivate
  def reactivate
    @user.update(deactivated: false)
    redirect_to users_url, notice: "#{@user.email} was successfully reactivated."
  end

  # PUT /users/1/promote
  def promote
    @user.update(is_admin: true)
    redirect_to users_url, notice: "#{@user.email} was successfully promoted to admin."
  end

  # PUT /users/1/demote
  def demote
    @user.update(is_admin: false)
    redirect_to users_url, notice: "#{@user.email} was successfully demoted from admin."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    # @user = User.find(params[:id]) if params[:id]
    @user = User.find(params[:user_id]) if params[:user_id]
  end
end
