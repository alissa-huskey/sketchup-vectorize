require "rake/testtask"
require "minitest/test_task"

desc "Initialize and update the development environment"
task :bootstrap do
  unless system("which bundle")
    title "Installing bundler"
    sh "gem install bundler"
  end

  title "Installing gems"
  sh 'bundle install'
end

Minitest::TestTask.create(:test) do |t|
  t.warning = false
  t.test_prelude = ['require "pry"']
end

task :default => :test
