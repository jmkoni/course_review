# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update destroy]
  before_action :set_school, only: %i[show new edit create update destroy]
  load_and_authorize_resource
  before_action :authenticate_user!, only: %i[new edit create update destroy]

  # GET /courses
  # GET /courses.json
  def index
    courses = Course.all.with_averages
    if params[:school_id].to_i.zero?
      (@filterrific = initialize_filterrific(
        courses,
        params[:filterrific],
        select_options: {
          sorted_by: Course.options_for_sorted_by,
          with_school_id: School.options_for_select
        }
      )) || return
    else
      set_school
      (@filterrific = initialize_filterrific(
        courses.where(school_id: @school.id),
        params[:filterrific],
        select_options: {
          sorted_by: Course.options_for_sorted_by
        }
      )) || return
    end
    @courses = @filterrific.find
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    @url = school_course_reviews_path(school_id: @school, course_id: @course)
    (@filterrific = initialize_filterrific(
      Review.preload(:user, course: [:school]).where(course_id: @course.id),
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
    @url = school_courses_path
  end

  # GET /courses/1/edit
  def edit
    @url = school_course_path
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html do
          redirect_to school_course_url(school_id: @school.id, id: @course.id),
                      notice: 'Course was successfully created.'
        end
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new }
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
          redirect_to school_course_url(school_id: @school.id, id: @course.id),
                      notice: 'Course was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to school_courses_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = School.find(params[:school_id])
  end

  def set_course
    @course = Course.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def course_params
    params.require(:course).permit(:name, :number, :department, :school_id)
  end
end
