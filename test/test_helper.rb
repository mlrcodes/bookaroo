ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase

    PASSWORD_TEST = "MySecurePassword#123"

    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Add more helper methods to be used by all tests here...  
  end
end
