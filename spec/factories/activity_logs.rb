# frozen_string_literal: true

FactoryBot.define do
  factory :activity_log do
    association :project
    association :user
    action   { 'created' }
    metadata { {} }
  end
end
