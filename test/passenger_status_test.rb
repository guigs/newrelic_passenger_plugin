require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '../lib/status_parser')
require "nokogiri"

class PassengerStatusTest < Test::Unit::TestCase

  def setup
    example_output_file = File.join(File.dirname(__FILE__), 'test_commands/passenger-status.xml')
    @status_parser = Status.new(File.read(example_output_file))
  end

  test "max possible passenger processes are parsed correctly" do
    assert_equal 6, @status_parser.max
  end

  test "number of running passenger processes are parsed correctly" do
    assert_equal 5, @status_parser.current
  end

  test "requests waiting on global queue are parsed correctly" do
    assert_equal 3, @status_parser.global_queue
  end

  test "number of sessions by app group parsed correctly" do
    assert_equal 2, @status_parser.sessions['test-app1']
    assert_equal 0, @status_parser.sessions['test-app2']
    assert_equal 1, @status_parser.sessions['test-app3']
  end

  test "total CPU by app group parsed correctly" do
    assert_equal 4.5, @status_parser.cpu['test-app1']
    assert_equal 3, @status_parser.cpu['test-app2']
    assert_equal 0, @status_parser.cpu['test-app3']
  end

  test "total memory by group app parsed correctly" do
    assert_equal 124736, @status_parser.memory['test-app1']
    assert_equal 65228, @status_parser.memory['test-app2']
    assert_equal 145212, @status_parser.memory['test-app3']
  end

  test "queue by group app parsed correctly" do
    assert_equal 2, @status_parser.queue['test-app1']
    assert_equal 0, @status_parser.queue['test-app2']
    assert_equal 1, @status_parser.queue['test-app3']
  end

  test "number of processes by group app parsed correctly" do
    assert_equal 3, @status_parser.processes['test-app1']
    assert_equal 1, @status_parser.processes['test-app2']
    assert_equal 1, @status_parser.processes['test-app3']
  end

end
