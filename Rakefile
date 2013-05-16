require 'bundler'
Bundler::GemHelper.install_tasks

# See https://github.com/colszowka/simplecov/issues/171
desc "Set permissions on all files so they are compatible with both user-local and system-wide installs"
task :fix_permissions do
  system 'bash -c "find . -type f -exec chmod 644 {} \; && find . -type d -exec chmod 755 {} \;"'
end
# Enforce proper permissions on each build
Rake::Task[:build].prerequisites.unshift :fix_permissions

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec