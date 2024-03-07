json.id contact.id
json.title contact.name
json.description contact.notes

if contact.due_all_day?
  json.start contact.due_date.to_date
  json.end contact.due_date.to_date + 1.day
else
  json.start contact.due_date.to_datetime.rfc3339
  json.end (contact.due_date + 30.minutes).to_datetime.rfc3339
end

json.allDay contact.due_all_day

json.list_name contact.list.name
