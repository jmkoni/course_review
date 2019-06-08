# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_review, only: %i[show edit update destroy]
  before_action :set_course, only: %i[show new edit create update destroy]
  before_action :set_school, only: %i[show new edit create update destroy]
  load_and_authorize_resource
  before_action :authenticate_user!, only: %i[new edit create update destroy]

  # GET /schools/1/courses/1/reviews
  # GET /schools/1/courses/1/reviews.json
  def index
    if params[:course_id].to_i.zero?
      if params[:school_id].to_i.zero?
        @reviews = Review.preload(:user, course: [:school]).all
      else
        set_school
        @reviews = Review.preload(:user, course: [:school]).joins(:course).where('courses.school_id = (?)', @school.id)
      end
    else
      set_school
      set_course
      @reviews = Review.preload(:user, course: [:school]).where(course_id: @course.id)
    end
  end

  # GET /schools/1/courses/1/reviews/1
  # GET /schools/1/courses/1/reviews/1.json
  def show; end

  # GET /schools/1/courses/1/reviews/new
  def new
    @review = Review.new
    @url = school_course_reviews_path
  end

  # GET /schools/1/courses/1/reviews/1/edit
  def edit
    @url = school_course_review_path
  end

  # POST /schools/1/courses/1/reviews
  # POST /schools/1/courses/1/reviews.json
  def create
    @url = school_course_reviews_path
    @review = Review.new(review_params)
    respond_to do |format|
      if @review.save
        format.html do
          redirect_to school_course_review_url(school_id: @school.id,
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
          redirect_to school_course_review_url(school_id: @school.id,
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
        redirect_to school_course_reviews_url(school_id: @school,
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
