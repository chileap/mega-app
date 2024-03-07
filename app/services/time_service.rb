class TimeService
  attr_reader :time

  def initialize(time)
    @time = time
  end

  def concat_time
    return unless time.present?
    hours = time.strftime("%H")
    minutes = time.strftime("%M")
    Time.new(2000, 0o1, 0o1, hours, minutes)
  end
end
