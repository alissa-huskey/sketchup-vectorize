require "minitest/test_task"
require "pathname"
require "json"
require "pry"

@rootdir = Pathname.new(__FILE__).parent.expand_path
@home = Pathname.new(Dir.home).expand_path
@sketchup_dir = @home/"Library"/"Application Support"/"Sketchup 2023"/"SketchUp"
@plugins_dir = @sketchup_dir/"Plugins"

def info(message)
  puts "\e[36m[rake]\e[0m: #{message}"
  exit 1
end

def warning(message)
  puts "\e[93mWarning\e[0m: #{message}"
  exit 1
end

def error(message)
  puts "\e[31mError\e[0m: #{message}"
  exit 1
end

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

namespace :sketchup do
  task :_open do
    sh("open", "-b", "com.sketchup.SketchUp.2023", @sketchup_file)
    @sketchup_file = nil
  end

  desc "Open the test model in SketchUp."
  task :test do
    @sketchup_file = "designs/model.skp"
    Rake::Task["sketchup:_open"].invoke
  end

  desc "Open the desk model in SketchUp."
  task :desk do
    @sketchup_file = (@home/"projects"/"office"/"desk"/"desk-etsy-legs.skp").to_s
    Rake::Task["sketchup:_open"].invoke
  end

  desc "Open an arbitrary model in SketchUp."
  task :open, [:path] do |_, args|
    error 'Please include path argument: `rake "sketchup:open[PATH]"`.' unless args.path
    @sketchup_file = args.path
    puts "Sketchup file: #{args.path}"
    Rake::Task["sketchup:_open"].invoke
  end
end
desc "Alias for sketchup:test"
task :sketchup => "sketchup:test"

namespace :log do
  desc "View log file"
  task :show do
    sh("tail", "-F", (@home/"Library"/"Logs"/"vectorize.log").to_s)
  end

  desc "View log of last bugsplat."
  task :splat do
    sh "less", (@sketchup_dir/"BugsplatPreviousLogFile.log").to_s
  end

  desc "View log of last crash."
  task :crash do
    logdir = @home/"Library"/"Logs"/"DiagnosticReports"
    files = FileList["#{logdir}/**/SketchUp-*.ips"]
    unless files
      warning "No crash logs found."
      return
    end

    last = files.sort { |a, b| a[/.*SketchUp-(.*)\.ips$/, 1] <=> b[/.*SketchUp-(.*)\.ips$/, 1] }.sort.last
    sh "tools/crash_report", last, verbose: false
  end
end
desc "Alias for log:show"
task :log => "log:show"

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
    warning "\e[93mWarning\e[0m: Yard server already running." if @doc_status
    YARD::CLI::CommandParser.run("server", "--reload")
  end

  desc "Stop yard daemon"
  task :stop => :_get_status do
    warning "\e[93mWarning\e[0m: No running yard server daemon found." unless @doc_status
    sh("pkill", "-f", "rake doc", "yard server", :verbose => false)
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
    warning "\e[93mWarning\e[0m: Yard server not running." unless @doc_status
    sh("open", "--url", "http://localhost:8808")
  end
end

desc "Alias for doc:start"
task :doc => "doc:start"

desc "Open an irb session preloaded with this library"
task :console do
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
  rm FileList[@plugins_dir/"vectorize.rb"], :verbose => false
  rm_r FileList[@plugins_dir/"vectorize"], :verbose => false

  # copy new plugin files
  cp FileList[@rootdir/"lib"/"vectorize.rb"], @plugins_dir, :verbose => false
  cp_r FileList[@rootdir/"lib"/"vectorize"], @plugins_dir, :verbose => false
end
