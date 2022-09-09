ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
require "bundler/setup" # Set up gems listed in the Gemfile.
begin
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
rescue LoadError
# bootsnap is an optional dependency, so if we don't have it it's fine
# Do not load in production because file system (where cache would be written) is read-only
nil
end