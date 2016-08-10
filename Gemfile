source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 3.3']
gem 'puppet', puppetversion
gem 'facter', '>= 1.7.0'

group :development, :test do
  gem 'puppetlabs_spec_helper', '>= 0.8.2'
  gem 'puppet-lint', '>= 1.0.0'
  gem 'webmock', '~> 2.1'
  gem 'simplecov', '~> 0.12.0'
  gem 'postgres-pr', '~> 0.7.0'
end
