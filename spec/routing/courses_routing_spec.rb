# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'schools/1/courses').to route_to('courses#index', school_id: '1')
    end

    it 'routes to #new' do
      expect(get: 'schools/1/courses/new').to route_to('courses#new', school_id: '1')
    end

    it 'routes to #show' do
      expect(get: 'schools/1/courses/1').to route_to('courses#show', id: '1', school_id: '1')
    end

    it 'routes to #edit' do
      expect(get: 'schools/1/courses/1/edit').to route_to('courses#edit', id: '1', school_id: '1')
    end

    it 'routes to #create' do
      expect(post: 'schools/1/courses').to route_to('courses#create', school_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: 'schools/1/courses/1').to route_to('courses#update', id: '1', school_id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: 'schools/1/courses/1').to route_to('courses#update', id: '1', school_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: 'schools/1/courses/1').to route_to('courses#destroy', id: '1', school_id: '1')
    end
  end
end
