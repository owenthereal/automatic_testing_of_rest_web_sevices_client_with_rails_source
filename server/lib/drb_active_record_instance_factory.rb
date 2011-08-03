require 'factory_girl'

class DRbActiveRecordInstanceFactory
  @@port = 9000

  def get_port_for_fixture_instance(factory_instance)
    port = create_port
    inst = Factory.create(factory_instance)
    DRb.start_service("druby://localhost:#{port}", inst)
    port
  end

  def create_port
    @@port += 1
  end
end
