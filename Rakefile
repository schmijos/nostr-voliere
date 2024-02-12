require "standard/rake"
require "minitest/test_task"
require "cucumber/rake/task"

Minitest::TestTask.create

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = %w[--format pretty]
end
