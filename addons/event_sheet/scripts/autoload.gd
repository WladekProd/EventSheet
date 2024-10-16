@tool
extends Node

var current_scene = null
var body_items: Dictionary

func _ready() -> void:
	if !Engine.is_editor_hint():
		var root = get_tree().root
		current_scene = root.get_child(root.get_child_count() - 1)
		_parse_event_sheet()
		
		for b in body_items:
			var on_start_of_layout: bool = false
			
			var events: Dictionary = body_items[b]["events"]
			var actions: Dictionary = body_items[b]["actions"]
			
			if events.size() > 0:
				for e in events:
					var event = events[e]
					var event_resource: WEvent = ResourceLoader.load(event["resource_path"])
					var parameters: Dictionary = event["new_parametrs"]
					match event_resource.id:
						"on_start_of_layout":
							on_start_of_layout = true
			
			if actions.size() > 0 and on_start_of_layout:
				for a in actions:
					var action = actions[a]
					var action_resource: WAction = ResourceLoader.load(action["resource_path"])
					var parameters: Dictionary = action["new_parametrs"]
					match action_resource.id:
						"create_object":
							var new_object = load(parameters["Object"]).instantiate()
							new_object.name = parameters["Name"]
							new_object.position = Vector2(int(parameters["X"]), int(parameters["Y"]))
							current_scene.add_child(new_object)

func _process(delta: float) -> void:
	pass

func _parse_event_sheet():
	var file_path = FileAccess.open("res://event_sheet/event_sheet.json", FileAccess.READ)

	var json_string = file_path.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var bodies = json.data
		if bodies.size() > 0:
			body_items = bodies
