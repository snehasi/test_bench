require "ostruct"

class Balance
  attr_reader :events

  def initialize(events)
    @events = balance_events(events)
  end

  def rows
    events.reduce([]) do |acc, event|
      adjustment  = adjustment(event)
      new_balance = (acc.last&.balance || 0) + adjustment(event)
      acc + [new_row(event, adjustment, new_balance)]
    end
  end

  private

  def new_row(event, adjustment, balance)
    row            = OpenStruct.new
    row.balance    = balance
    row.adjustment = adjustment
    row.id         = event.id
    row.uuid       = event.uuid
    row.date       = event.projected_at.strftime("%m-%d %H:%M:%S")
    row.cmd_type   = event.cmd_type
    row.event_type = event.event_type.gsub("Event::", "")
    row.payload    = event.payload
    row.note       = event.note
    row
  end

  def adjustment(event)
    increment_types = %w(UserDeposited)
    type   = event.event_type.split("::").last
    amount = event.payload["amount"] || 0
    increment_types.include?(type) ? amount : -1 * amount
  end

  def balance_events(events)
    list = %w(UserCreated UserDeposited UserWithdrawn)
    events.to_a.select do |event|
      type = event.event_type.split("::").last
      list.include?(type)
    end
  end
end