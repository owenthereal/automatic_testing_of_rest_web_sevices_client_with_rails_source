require 'spec_helper'

describe Task do
  before :all do
    DRb.start_service
    @remote_base = DRbObject.new nil, "druby://localhost:8000"
    @drb_factory = DRbObject.new(nil, 'druby://localhost:9000')
  end

  before :each do
    begin_remote_transaction
  end

  after :each do
    rollback_remote_transaction
  end

  it "creates a task" do
    task = Task.create(:name => "ruby meetup")
    task.name.should == "ruby meetup"
  end

  it "gets a task back" do
    remote_task_port = @drb_factory.get_port_for_fixture_instance(:task)
    @remote_task = DRbObject.new(nil, "druby://localhost:#{remote_task_port}")

    Task.all.size.should == 1
    Task.first.name.should == @remote_task.name
    Task.first.id.should == @remote_task.id
  end

  private

  def begin_remote_transaction
    @remote_base.connection.increment_open_transactions
    @remote_base.connection.transaction_joinable = false
    @remote_base.connection.begin_db_transaction
  end

  def rollback_remote_transaction
    @remote_base.connection.rollback_db_transaction
    @remote_base.connection.decrement_open_transactions
    @remote_base.clear_active_connections!
  end
end
