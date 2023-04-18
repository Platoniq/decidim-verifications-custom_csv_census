# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.25.0"

gem "decidim", DECIDIM_VERSION

group :development, :test do
  gem "bootsnap"
  gem "byebug", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "faker", "~> 1"
  gem "listen"
end
