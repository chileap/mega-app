class ApplicationWorkflow
  def self.call(*args, &block)
    new(*args).call
  end

  def call
    raise "need to implement method call"
  end
end
