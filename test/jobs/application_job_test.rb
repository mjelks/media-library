require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  test "ApplicationJob inherits from ActiveJob::Base" do
    assert ApplicationJob < ActiveJob::Base
  end

  test "ApplicationJob is defined" do
    assert_kind_of Class, ApplicationJob
  end

  test "ApplicationJob can be subclassed" do
    test_job_class = Class.new(ApplicationJob)
    assert test_job_class < ApplicationJob
    assert test_job_class < ActiveJob::Base
  end
end
