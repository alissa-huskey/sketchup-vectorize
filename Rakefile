require "rake/testtask"
require "minitest/test_task"

desc "Initialize and update the development environment"
task :bootstrap do
  if not system("which bundle")
    title "Installing bundler"
    sh "gem install bundler"
  end

  title "Installing gems"
  sh 'bundle install'
end

Minitest::TestTask.create(:test) do |t|
  t.warning = false
end


task :default => :test
