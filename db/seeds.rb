# frozen_string_literal: true

user = User.find_or_create_by!(email: 'demo@studioflow.app') do |u|
  u.password = 'password123'
end

Project.find_or_create_by!(name: 'Brand Refresh', owner: user) do |p|
  p.client   = 'Acme Corp'
  p.status   = 'active'
  p.progress = 40
  p.category = 'Branding'
  p.tag_list = %w[Design React]
end

Rails.logger.debug { "Seeded #{User.count} users and #{Project.count} projects." }
