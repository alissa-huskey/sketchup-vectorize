require "minitest/test_task"
require "pathname"

@rootdir = Pathname.new(__FILE__).parent.expand_path
@home = Pathname.new(Dir.home).expand_path
@plugins_dir = @home/"Library"/"Application Support"/"Sketchup 2023"/"SketchUp"/"Plugins"

desc "Initialize and update the development environment"
task :bootstrap do
  sh(*%w[which bundle], :verbose => false) do |ok, _|
    unless ok
      puts "Installing bundler"
      sh %w[gem install bundler]
    end
  end

  puts "Installing gems"
  sh %w[bundle install]
end

desc "Install and update gems from Gemfile"
task :update => :bootstrap

Minitest::TestTask.create(:test) do |t|
  t.warning = false
  t.test_prelude = ['require "pry"']
end

desc "Open the test model in SketchUp."
task :sketchup do
  sh("open", "-b", "com.sketchup.SketchUp.2023", "designs/model.skp")
end

namespace :doc do
  require 'yard'

  task :_get_status do
    sh("pgrep", "-f", "-q", "rake doc", "yard server", :verbose => false) do |ok, _|
      @doc_status = ok
    end
  end

  desc "Show status of yard daemon"
  task :status => :_get_status do
    status = (@doc_status ? "\e[36mrunning\e[0m" : "\e[31mnot running\e[0m")
    puts "Status: #{status}"
  end

  desc "Start yard daemon"
  task :start => :_get_status do
    if @doc_status
      puts "\e[93mWarning\e[0m: Yard server already running."
    else
      YARD::CLI::CommandParser.run("server", "--reload")
    end
  end

  desc "Stop yard daemon"
  task :stop => :_get_status do
    if !@doc_status
      puts "\e[93mWarning\e[0m: No running yard server daemon found."
    else
      sh("pkill", "-f", "rake doc", "yard server", :verbose => false)
    end
  end

  desc "Generate docs."
  task :build do
    YARD::CLI::CommandParser.run("doc")
  end

  desc "Remove all generated docs."
  task :clean do
    %w[.yardoc doc].each { |dir| FileUtils.rm_r(dir, :force => true) }
  end

  desc "Build docs from scratch."
  task :rebuild => %i[clean build]

  desc "List undocumented code"
  task :todo do
    YARD::CLI::CommandParser.run("stats", "--list-undoc")
  end

  desc "View docs in browser"
  task :view => :_get_status do
    if !@doc_status
      puts "\e[93mWarning\e[0m: Yard server not running."
    else
      sh("open", "--url", "http://localhost:8808")
    end
  end
end

desc "Alias for doc:start"
task :doc => "doc:start"

desc "Open an irb session preloaded with this library"
task :console do
  require "pry"
  require "matrix"
  require 'sketchup-api-stubs/sketchup'
  require_relative "test/mocks"

  require "bundler/setup"
  Bundler.require

  Dir["#{__dir__}/lib/**/*.rb"].each { |f| require f }

  Pry.start || exit
end

desc "Alias for test"
task :default => :test

desc "Build the vectorize.rbz file"
task :build do
  Dir.chdir(@rootdir/"lib") do
    files = FileList["**/*.rb"]
    sh("zip", "extension.rbz", *files)
    FileUtils.mv(@rootdir/"lib"/"extension.rbz", @rootdir/"extension.rbz")
  end
end

desc "Install files to SketchUp plugin directory"
task :install do
  # remove old plugin files
  rm FileList[@plugins_dir/"vectorize.rb"], :verbose => true
  rm_r FileList[@plugins_dir/"vectorize"], :verbose => true

  # copy new plugin files
  cp FileList[@rootdir/"lib"/"vectorize.rb"], @plugins_dir, :verbose => true
  cp_r FileList[@rootdir/"lib"/"vectorize"], @plugins_dir, :verbose => true
end
