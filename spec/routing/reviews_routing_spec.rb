# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'schools/1/departments/1/courses/1/reviews').to route_to('reviews#index', school_id: '1', department_id: '1', course_id: '1')
    end

    it 'routes to #new' do
      expect(get: 'schools/1/departments/1/courses/1/reviews/new').to route_to('reviews#new', school_id: '1', department_id: '1', course_id: '1')
    end

    it 'routes to #show' do
      expect(get: 'schools/1/departments/1/courses/1/reviews/1').to route_to('reviews#show', id: '1', school_id: '1', department_id: '1', course_id: '1')
    end

    it 'routes to #edit' do
      expect(get: 'schools/1/departments/1/courses/1/reviews/1/edit').to route_to('reviews#edit', id: '1', school_id: '1', department_id: '1', course_id: '1')
    end

    it 'routes to #create' do
      expect(post: 'schools/1/departments/1/courses/1/reviews').to route_to('reviews#create', school_id: '1', department_id: '1', course_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: 'schools/1/departments/1/courses/1/reviews/1').to route_to('reviews#update', id: '1', school_id: '1', department_id: '1', course_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: 'schools/1/departments/1/courses/1/reviews/1').to route_to('reviews#update', id: '1', school_id: '1', department_id: '1', course_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: 'schools/1/departments/1/courses/1/reviews/1').to route_to('reviews#destroy', id: '1', school_id: '1', department_id: '1', course_id: '1')
    end
  end
end
