# frozen_string_literal: true

class DepartmentsController < ApplicationController
  before_action :set_department, only: %i[show edit update destroy]
  before_action :set_school, only: %i[show new edit create update destroy]
  load_and_authorize_resource
  before_action :authenticate_user!, only: %i[new edit create update destroy]

  # GET /departments
  # GET /departments.json
  def index
    departments = Department.with_averages
    if params[:school_id].to_i.zero?
      (@filterrific = initialize_filterrific(
        departments,
        params[:filterrific],
        select_options: {
          sorted_by: Department.options_for_sorted_by,
          with_school_id: School.options_for_select
        }
      )) || return
    else
      set_school
      (@filterrific = initialize_filterrific(
        departments.where('departments.school_id = ?', @school.id),
        params[:filterrific],
        select_options: {
          sorted_by: Department.options_for_sorted_by
        }
      )) || return
    end
    @departments = @filterrific.find
  end

  # GET /departments/1
  # GET /departments/1.json
  def show
    @url = school_department_courses_path(school_id: @school.id, department_id: @department.id)
    (@filterrific = initialize_filterrific(
      Course.with_averages.where(department_id: @department.id),
      params[:filterrific],
      select_options: {
        sorted_by: Course.options_for_sorted_by
      }
    )) || return
    @courses = @filterrific.find
  end

  # GET /departments/new
  def new
    @department = Department.new
    @url = school_departments_path
  end

  # GET /departments/1/edit
  def edit
    @url = school_department_path
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.new(department_params)
    respond_to do |format|
      if @department.save
        format.html do
          redirect_to school_department_url(school_id: @school.id, id: @department.id),
                      notice: 'Department was successfully created.'
        end
        format.json { render :show, status: :created, location: @department }
      else
        format.html { render :new }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html do
          redirect_to school_department_url(school_id: @school.id, id: @department.id),
                      notice: 'Department was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @department }
      else
        format.html { render :edit }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    @department.destroy
    respond_to do |format|
      format.html { redirect_to school_departments_url, notice: 'Department was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_department
    @department = Department.find(params[:id])
  end

  def set_school
    @school = School.find(params[:school_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def department_params
    params.require(:department).permit(:name, :short_name, :school_id)
  end
end
