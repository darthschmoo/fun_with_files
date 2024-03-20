source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.

group :development do
  gem "debug"
  gem "fun_with_testing", "~> 0.0", ">= 0.0.7"
end


xdg_version = case RUBY_VERSION
              when /^2\.7/
                3
              when /^3\.0/
                5
              when /^3\.2/
                7
              end


              
gem "xdg", "~> #{xdg_version}"


