require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
desc "Run the specs under spec"
RSpec::Core::RakeTask.new

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb'] - FileList['test/acceptance/**/*_test.rb']
  t.verbose = true
end

require 'rake/testtask'
desc 'Run acceptance tests (Scheme programs inside examples/ directory)'
Rake::TestTask.new :acceptance do |t|
  t.libs << "test"
  t.test_files = FileList['test/acceptance/**/*_test.rb']
  t.verbose = true
end

task :default => :test
