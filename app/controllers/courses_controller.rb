# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update destroy]
  before_action :set_department, only: %i[show new edit create update destroy]
  before_action :set_school, only: %i[show new edit create update destroy]
  load_and_authorize_resource
  before_action :authenticate_user!, only: %i[new edit create update destroy]

  # GET /courses
  # GET /courses.json
  # rubocop:disable Metrics/PerceivedComplexity
  def index
    courses = Course.with_averages
    if params[:department_id].to_i.zero?
      if params[:school_id].to_i.zero?
        (@filterrific = initialize_filterrific(
          courses,
          params[:filterrific],
          select_options: {
            sorted_by: Course.options_for_sorted_by,
            with_school_id: School.options_for_select,
            with_department_id: Department.options_for_select
          }
        )) || return
      else
        set_school
        (@filterrific = initialize_filterrific(
          courses.where('departments.school_id = ?', @school.id),
          params[:filterrific],
          select_options: {
            sorted_by: Course.options_for_sorted_by,
            with_department_id: Department.where(school_id: @school.id).options_for_select
          }
        )) || return
      end
    else
      set_school
      set_department
      (@filterrific = initialize_filterrific(
        courses.where(department_id: @department.id),
        params[:filterrific],
        select_options: {
          sorted_by: Course.options_for_sorted_by
        }
      )) || return
    end
    @courses = Kaminari.paginate_array(@filterrific.find).page(params[:page])
  end
  # rubocop:enable Metrics/PerceivedComplexity

  # GET /courses/1
  # GET /courses/1.json
  def show
    @url = school_department_course_reviews_path(school_id: @school.id, department_id: @department.id, course_id: @course.id)
    (@filterrific = initialize_filterrific(
      Review.preload(:user, course: { department: :school }).where(course_id: @course.id),
      params[:filterrific],
      select_options: {
        sorted_by: Review.options_for_sorted_by
      }
    )) || return
    @reviews = @filterrific.find.page(params[:page])
  end

  # GET /courses/new
  def new
    @course = Course.new
    @url = school_department_courses_path(school_id: @school.id, department_id: @department.id)
  end

  # GET /courses/1/edit
  def edit
    @url = school_department_course_path(school_id: @school.id, department_id: @department.id, id: @course.id)
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html do
          redirect_to school_department_course_url(school_id: @school.id, department_id: @department.id, id: @course.id),
                      notice: 'Course was successfully created.'
        end
        format.json { render :show, status: :created, location: @course }
      else
        format.html do
          @url = school_department_courses_path(school_id: @school.id, department_id: @department.id)
          render :new
        end
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html do
          redirect_to school_department_course_url(school_id: @school.id, department_id: @department.id, id: @course.id),
                      notice: 'Course was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @course }
      else
        format.html do
          @url = school_department_course_path(school_id: @school.id, department_id: @department.id, id: @course.id)
          render :edit
        end
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to school_department_courses_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = School.find(params[:school_id])
  end

  def set_department
    @department = Department.find(params[:department_id])
  end

  def set_course
    @course = Course.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def course_params
    params.require(:course).permit(:name, :number, :department_id)
  end
end
