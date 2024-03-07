class ApplicationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 5

  def perform(*args)
    raise NotImplementedError, "You must implement the #perform method in your worker"
  end
end
