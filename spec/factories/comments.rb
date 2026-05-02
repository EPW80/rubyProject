# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    association :project
    association :user
    body { Faker::Lorem.sentence }
  end
end
