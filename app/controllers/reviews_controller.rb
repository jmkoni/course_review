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
  def index
    reviews = Review.preload(:user, course: { department: :school })
    select_options = { sorted_by: Review.options_for_sorted_by }
    if params[:school_id].to_i.zero?
      select_options.merge!(
        with_course_id: Course.options_for_select,
        with_department_id: Department.options_for_select,
        with_school_id: School.options_for_select
      )
    end

    if school_id_exists
      set_school
      reviews = reviews.joins(course: :department)
                       .where('departments.school_id = (?)', @school.id)
      select_options[:with_course_id] = Course.joins(:department)
                                              .where('departments.school_id = ?', @school.id)
                                              .options_for_select
      select_options[:with_department_id] = Department.where(school_id: @school.id).options_for_select
    end

    if department_id_exists
      set_department
      reviews = reviews.where('courses.department_id = (?)', @department.id)
      select_options.delete(:with_department_id)
      select_options[:with_course_id] = Course.where(department_id: @department.id).options_for_select
    end

    if course_id_exists
      set_course
      select_options.delete(:with_course_id)
      reviews = reviews.where(course_id: @course.id)
    end

    (@filterrific = initialize_filterrific(
      reviews,
      params[:filterrific],
      select_options: select_options
    )) || return
    @reviews = @filterrific.find.page(params[:page])
  end

  # GET /schools/1/courses/1/reviews/1
  # GET /schools/1/courses/1/reviews/1.json
  def show; end

  # GET /schools/1/courses/1/reviews/new
  def new
    @review = Review.new
    @user = current_user
    @url = school_department_course_reviews_path
  end

  # GET /schools/1/courses/1/reviews/1/edit
  def edit
    @user = @review.user
    @url = school_department_course_review_path
  end

  # POST /schools/1/courses/1/reviews
  # POST /schools/1/courses/1/reviews.json
  def create
    @user = current_user
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
    @user = @review.user
    @url = school_department_course_review_path
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

  def department_id_exists
    !params[:department_id].to_i.zero?
  end

  def school_id_exists
    !params[:school_id].to_i.zero?
  end

  def course_id_exists
    !params[:course_id].to_i.zero?
  end

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
                                   :grade,
                                   :teacher)
  end
end
