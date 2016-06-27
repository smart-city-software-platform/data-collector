require 'singleton'

# This class is a singleton supervisor to manage workers. Usually, we have a
# lot of workers collecting data from thousands of resources because of this
# we have to control basic things related to it.
class WorkerSupervisor

  include Singleton

  @@resource_id_status = $redis

  INACTIVE ||= 0
  ACTIVE ||= 1
  UPDATED ||= 2

  def set_resource_collector_status(resource_id, status)
    @@resource_id_status[resource_id] = status
  end

  def resource_status(resource_id)
    @@resource_id_status[resource_id] || INACTIVE
  end

  def resource_updated?(resource_id)
    resource_status(resource_id) == UPDATED
  end

  def resource_inactive?(resource_id)
    resource_status(resource_id) == INACTIVE
  end

  def set_resource_as_active(resource_id)
    @@resource_id_status[resource_id] = ACTIVE
  end

  def start_collect(uri, resource_id, collect_interval)
    CollectData.perform_async(uri, resource_id, collect_interval)
  end

end
