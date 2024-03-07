json.id task.id
json.title task.name
json.description task.notes

if task.due_all_day?
  json.start task.due_date.to_date
  json.end task.due_date.to_date + 1.day
else
  json.start task.due_date.to_datetime.rfc3339
  json.end (task.due_date + 30.minutes).to_datetime.rfc3339
end

json.allDay task.due_all_day

json.list_name task.list.name
