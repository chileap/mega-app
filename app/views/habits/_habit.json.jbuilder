json.id habit.id
json.title habit.title
json.goal_name habit.goal_title
json.start habit.start_date_time&.in_time_zone&.rfc3339
json.end habit.end_date_time&.in_time_zone&.rfc3339
json.rrule habit.rrule
json.allDay habit.time.present?
