# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    association :owner, factory: :user
    sequence(:name) { |n| "Project #{n}" }
    client   { Faker::Company.name }
    status   { 'active' }
    progress { 0 }
    category { 'Web App' }
    tag_list { [] }
  end
end
