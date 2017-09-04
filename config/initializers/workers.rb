if Rails.env.development? || Rails.env.production?
  WORKERS_LOGGER ||= Logger.new("#{Rails.root}/log/workers.log")

  $conn = Bunny.new(
    hostname: SERVICES_CONFIG['services']['rabbitmq'],
    logger: WORKERS_LOGGER,
  )
  $conn.start

  resource_creator_worker = ResourceCreator.new(2, 2)
  resource_creator_worker.perform

  resource_updater_worker = ResourceUpdater.new(1, 1)
  resource_updater_worker.perform

  data_receiver_worker = DataReceiver.new(3, 3)
  data_receiver_worker.perform
end
