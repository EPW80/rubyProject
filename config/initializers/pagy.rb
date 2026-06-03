# frozen_string_literal: true

require 'pagy/extras/overflow'

# Default page size for the API.
Pagy::DEFAULT[:limit] = 25

# Out-of-range pages return an empty page (like will_paginate) instead of raising.
Pagy::DEFAULT[:overflow] = :empty_page
