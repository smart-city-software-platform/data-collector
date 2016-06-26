require 'singleton'

# This class is a singleton supervisor to manage workers. Usually, we have a
# lot of workers collecting data from thousands of resources because of this
# we have to control basic things related to it.
class WorkerSupervisor
  include Singleton

  # @map_worker_byId

  def initialize
    # @map_worker_by_id = {}
  end

  # Based on the new resource, we have to request periodically data
  # to /basic_resources/:id/components and handle it. This method, build the
  # URI and perform the required work.
  def create_worker(resource_id)
    # PygmentsWorker.perform_async(@snippet.id)
    register_worker(resource_id)
  end

  # Sometimes, we need to start and stopped worker. It is possible to do it
  # when some method provides the Id from resource.
  # @param resource_id Target resource to start collect.
  def start_worker(resource_id)
    # TODO
  end

  # Find a resource with worker currently running and stopped it.
  # @param resource_id Target to stop.
  def stop_worker(resource_id)
    # TODO
  end

  # Verify if has an worker running, if it has destroy each one. If no
  # workers are currently running, go to database and start to collect
  # all data.
  def spawn_workers
    # TODO
  end

  # Just take a target id associate it with a PID from worker in a hash.
  # @param resource_id
  def register_worker(resource_id)
    # TODO
  end
end
