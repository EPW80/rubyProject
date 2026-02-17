FactoryBot.define do
  factory :milestone do
    association :project
    sequence(:title) { |n| "Milestone #{n}" }
    completed { false }
    due_date  { 1.month.from_now }
  end
end
