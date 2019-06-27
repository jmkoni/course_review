# typed: false
# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_review, only: %i[show edit update destroy]
  before_action :set_course, only: %i[show new edit create update destroy]
  before_action :set_department, only: %i[show new edit create update destroy]
  before_action :set_school, only: %i[show new edit create update destroy]
  load_and_authorize_resource
  before_action :authenticate_user!, only: %i[new edit create update destroy]

  # GET /schools/1/courses/1/reviews
  # GET /schools/1/courses/1/reviews.json
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def index
    if params[:course_id].to_i.zero?
      if params[:department_id].to_i.zero?
        if params[:school_id].to_i.zero?
          (@filterrific = initialize_filterrific(
            Review.preload(:user, course: { department: :school }),
            params[:filterrific],
            select_options: {
              sorted_by: Review.options_for_sorted_by,
              with_course_id: Course.options_for_select,
              with_department_id: Department.options_for_select,
              with_school_id: School.options_for_select
            }
          )) || return
        else
          set_school
          (@filterrific = initialize_filterrific(
            Review.preload(:user, course: { department: :school })
                  .joins(course: :department)
                  .where('departments.school_id = (?)', @school.id),
            params[:filterrific],
            select_options: {
              sorted_by: Review.options_for_sorted_by,
              with_course_id: Course.joins(:department)
              .where('departments.school_id = ?', @school.id)
              .options_for_select,
              with_department_id: Department.where(school_id: @school.id).options_for_select
            }
          )) || return
        end
      else
        set_school
        set_department
        (@filterrific = initialize_filterrific(
          Review.preload(:user, course: { department: :school })
                .joins(course: :department)
                .where('courses.department_id = (?) and departments.school_id = (?)',
                       @department.id,
                       @school.id),
          params[:filterrific],
          select_options: {
            sorted_by: Review.options_for_sorted_by,
            with_course_id: Course.where(department_id: @department.id).options_for_select
          }
        )) || return
      end
    else
      set_school
      set_department
      set_course
      (@filterrific = initialize_filterrific(
        Review.preload(:user, course: { department: :school }).where(course_id: @course.id),
        params[:filterrific],
        select_options: {
          sorted_by: Review.options_for_sorted_by
        }
      )) || return
    end
    @reviews = @filterrific.find.page(params[:page])
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  # GET /schools/1/courses/1/reviews/1
  # GET /schools/1/courses/1/reviews/1.json
  def show; end

  # GET /schools/1/courses/1/reviews/new
  def new
    @review = Review.new
    @url = school_department_course_reviews_path
  end

  # GET /schools/1/courses/1/reviews/1/edit
  def edit
    @url = school_department_course_review_path
  end

  # POST /schools/1/courses/1/reviews
  # POST /schools/1/courses/1/reviews.json
  def create
    @url = school_department_course_reviews_path
    @review = Review.new(review_params)
    respond_to do |format|
      if @review.save
        format.html do
          redirect_to school_department_course_review_url(school_id: @school.id,
                                                          department_id: @department.id,
                                                          course_id: @course.id,
                                                          id: @review.id),
                      notice: 'Review was successfully created.'
        end
        format.json { render :show, status: :created, location: @review }
      else
        format.html { render :new }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schools/1/courses/1/reviews/1
  # PATCH/PUT /schools/1/courses/1/reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html do
          redirect_to school_department_course_review_url(school_id: @school.id,
                                                          department_id: @department.id,
                                                          course_id: @course.id,
                                                          id: @review.id),
                      notice: 'Review was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schools/1/courses/1/reviews/1
  # DELETE /schools/1/courses/1/reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.html do
        redirect_to school_department_course_reviews_url(school_id: @school,
                                                         course_id: @course),
                    notice: 'Review was successfully destroyed.'
      end
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
    @course = Course.find(params[:course_id])
  end

  def set_review
    @review = Review.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def review_params
    params.require(:review).permit(:course_id,
                                   :user_id,
                                   :notes,
                                   :work_required,
                                   :difficulty,
                                   :rating,
                                   :experience_with_topic,
                                   :year,
                                   :term,
                                   :grade)
  end
end
