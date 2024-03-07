class ApplicationService
  def self.call(*args)
    new(*args).call
  end

  def call
    raise "need to implement method call"
  end
end
