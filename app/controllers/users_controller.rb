# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit promote demote update destroy]
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/new
  def new
    @user = User.new
  end

  def edit; end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: "User #{@user.email} was successfully created." }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_url, notice: 'User was successfully updated.' }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PUT /users/1/promote
  def promote
    @user.update(is_admin: true)
    redirect_to users_url, notice: "#{@user.email} was successfully demoted from admin."
  end

  # PUT /users/1/demote
  def demote
    @user.update(is_admin: false)
    redirect_to users_url, notice: "#{@user.email} was successfully demoted from admin."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id]) if params[:id]
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :years_experience, :is_admin)
  end
end
