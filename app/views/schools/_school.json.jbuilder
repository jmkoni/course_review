# frozen_string_literal: true

json.extract! school, :id, :name, :short_name, :created_at, :updated_at
json.url school_url(school, format: :json)
