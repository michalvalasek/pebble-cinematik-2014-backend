json.id event.id
json.name I18n.transliterate(event.name)
json.original_name I18n.transliterate(event.original_name) if event.original_name
json.day event.day
json.time event.time
json.place I18n.transliterate(event.place)
json.section I18n.transliterate(event.section) if event.section
json.director I18n.transliterate(event.director) if event.director
json.meta event.meta if event.meta