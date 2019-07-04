# frozen_string_literal: true

class SchoolsController < ApplicationController
  before_action :set_school, only: %i[edit show update destroy]
  load_and_authorize_resource
  before_action :authenticate_user!, only: %i[new edit create update destroy]

  # GET /schools
  # GET /schools.json
  def index
    (@filterrific = initialize_filterrific(
      School.with_averages,
      params[:filterrific],
      select_options: {
        sorted_by: School.options_for_sorted_by
      }
    )) || return
    @schools = Kaminari.paginate_array(@filterrific.find).page(params[:page])
  end

  # GET /schools/1
  def show
    redirect_to school_departments_path(school_id: @school.id)
  end

  # GET /schools/new
  def new
    @school = School.new
  end

  # GET /schools/1/edit
  def edit; end

  # POST /schools
  # POST /schools.json
  def create
    @school = School.new(school_params)

    respond_to do |format|
      if @school.save
        format.html { redirect_to schools_url, notice: 'School was successfully created.' }
      else
        format.html { render :new }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schools/1
  # PATCH/PUT /schools/1.json
  def update
    respond_to do |format|
      if @school.update(school_params)
        format.html { redirect_to schools_url, notice: 'School was successfully updated.' }
      else
        format.html { render :edit }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schools/1
  # DELETE /schools/1.json
  def destroy
    @school.destroy
    respond_to do |format|
      format.html { redirect_to schools_url, notice: 'School was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = School.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def school_params
    params.require(:school).permit(:name, :short_name)
  end
end
