# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/users').to route_to('users#index')
    end

    it 'routes to #promote via PUT' do
      expect(put: '/users/1/promote').to route_to('users#promote', user_id: '1')
    end

    it 'routes to #demote via PUT' do
      expect(put: '/users/1/demote').to route_to('users#demote', user_id: '1')
    end

    it 'routes to #deactivate via PUT' do
      expect(put: '/users/1/deactivate').to route_to('users#deactivate', user_id: '1')
    end

    it 'routes to #reactivate via PUT' do
      expect(put: '/users/1/reactivate').to route_to('users#reactivate', user_id: '1')
    end
  end
end
