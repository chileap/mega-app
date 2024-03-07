json.id event.id
json.title event.name
json.description event.description

if event.all_day?
  json.start event.start_time.to_date
  json.end event.end_time.to_date + 1.day
  json.exdate event.repeat_except_dates.map { |date| date.to_date.to_s }
else
  json.start event.start_time.to_datetime.rfc3339
  json.end event.end_time.to_datetime.rfc3339
  json.exdate event.repeat_except_dates.map { |date| date.to_datetime.rfc3339 }
end

json.allDay event.all_day
json.overlap event.is_overlap?
json.rrule event.rrule
json.duration event.duration
json.color event.color
