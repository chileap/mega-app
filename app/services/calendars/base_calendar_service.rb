class Calendars::BaseCalendarService
  attr_reader :account, :client

  def initialize(account)
    @account = account
    @client = "#{account.provider.to_s.camelize}Client".constantize.new(account)
  end

  def serialize_recurrence(recurrence)
    return if recurrence.blank?
    rrule_hash = {}

    recurrence.each do |rule|
      if rule.include?("EXDATE")
        exdate = rule.split("=").last.split(",").map do |date|
          date.to_date.strftime("%Y-%m-%d")
        end
        rrule_hash["EXDATE"] = exdate
        next
      end

      new_rule = rule.split(";")
      new_rule.each do |rule|
        key = rule.split("=").first.split("RRULE:").last

        rrule_hash[key] = rule.split("=").last
      end
    end

    rrule_hash
  end
end
