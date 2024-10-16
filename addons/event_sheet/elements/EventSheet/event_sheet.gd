@tool
extends Panel

@onready var blank_body_items: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var popup_menu: PopupMenu = $PopupMenu

@onready var window_add: Window = $AddWindow
@onready var window_add_event_or_action: Window = $AddEventOrAction
@onready var window_set_parametr: Window = $SetParameter

var shortcut: Shortcut = EditorInterface.get_editor_settings().get_setting("plugins/event_sheet/shortcut")
var current_menu: String = "general"
var popup_menus: Dictionary = {
	"general": ["Add Blank Event"],
	"blank_body": ["Add Event", "Add Action", "", "Delete Blank Event"],
	"event": ["Edit Event", "Add Event", "", "Delete Event"],
	"action": ["Edit Action", "Add Action", "", "Delete Action"]
}
var is_mouse_focused: bool = false
var event_sheet_data: Dictionary = {}

@onready var current_scene = load("res://demo_project/demo_scene.tscn").instantiate()
var current_blank_body
var current_event
var current_action

func _ready() -> void:
	load_event_sheet()

func _process(delta: float) -> void:
	pass

func _shortcut_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if shortcut.matches_event(event):
		save_event_sheet()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click and is_mouse_focused:
			show_add_window("event")
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and is_mouse_focused:
			show_popup_menu()

func save_event_sheet():
	var rescan_filesystem = false
	var dirs = [
		"res://event_sheet"
	]
	
	event_sheet_data.clear()
	for i in blank_body_items.get_child_count():
		var event = blank_body_items.get_child(i)
		event_sheet_data[i] = event._save()
	
	for dir in dirs:
		if !DirAccess.dir_exists_absolute(dir):
			DirAccess.make_dir_absolute(dir)
			rescan_filesystem = true
	
	var files_count: int = DirAccess.get_files_at(dirs[0]).size()
	var file_name = "{0}/event_sheet.json".format([dirs[0]])
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	if event_sheet_data.size() > 0:
		file.store_line(JSON.stringify(event_sheet_data))
	else:
		file.store_line(JSON.stringify({}))
	rescan_filesystem = true
	file.close()
	
	if rescan_filesystem: EditorInterface.get_resource_filesystem().scan()

func load_event_sheet():
	var file_path = FileAccess.open("res://event_sheet/event_sheet.json", FileAccess.READ)

	var json_string = file_path.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var bodies = json.data
		
		if bodies.size() > 0:
			for b in bodies:
				var blank_body = add_blank_body()
				
				var events: Dictionary = bodies[b]["events"]
				var actions: Dictionary = bodies[b]["actions"]
				
				if events.size() > 0:
					for e in events:
						var event = events[e]
						var group_resource: WGroup = ResourceLoader.load(event["group_resource_path"])
						var event_resource: WEvent = ResourceLoader.load(event["resource_path"])
						var parameters: Dictionary = event["new_parametrs"]
						add_event(group_resource, event_resource, false, parameters, blank_body)
				
				if actions.size() > 0:
					for a in actions:
						var action = actions[a]
						var group_resource: WGroup = ResourceLoader.load(action["group_resource_path"])
						var action_resource: WAction = ResourceLoader.load(action["resource_path"])
						var parameters: Dictionary = action["new_parametrs"]
						add_action(group_resource, action_resource, false, parameters, blank_body)

func add_blank_body():
	var blank_body = load("res://addons/event_sheet/elements/Blank Body/blank_body.tscn").instantiate()
	blank_body.add_action_button.connect(_on_add_action_button_clicked)
	blank_body.bb_popup_button.connect(_on_blank_body_clicked)
	blank_body_items.add_child(blank_body)
	#save_event_sheet()
	return blank_body

func add_event(group_res: WGroup, event_res: WEvent, change_selected_body: bool, new_data: Dictionary, body = null):
	var new_blank_body
	if !change_selected_body:
		if !body:
			new_blank_body = load("res://addons/event_sheet/elements/Blank Body/blank_body.tscn").instantiate()
			new_blank_body.add_action_button.connect(_on_add_action_button_clicked)
			new_blank_body.bb_popup_button.connect(_on_blank_body_clicked)
			blank_body_items.add_child(new_blank_body)
		else:
			new_blank_body = body
		
		var new_event = load("res://addons/event_sheet/elements/Event/event.tscn").instantiate()
		new_event.group_resource = group_res
		new_event.event_resource = event_res
		if new_data.size() > 0: new_event.new_data = new_data
		new_event.event_clicked.connect(_on_event_clicked)
		new_event.blank_body = new_blank_body
		
		new_blank_body.blank_body_tree.add_child(new_event)
		new_blank_body.events.append(new_event)
	else:
		if current_blank_body:
			var new_event = load("res://addons/event_sheet/elements/Event/event.tscn").instantiate()
			new_event.group_resource = group_res
			new_event.event_resource = event_res
			if new_data.size() > 0: new_event.new_data = new_data
			new_event.event_clicked.connect(_on_event_clicked)
			new_event.blank_body = current_blank_body
			
			current_blank_body.blank_body_tree.add_child(new_event)
			current_blank_body.events.append(new_event)
		else:
			add_event(group_res, event_res, false, new_data)

func add_action(group_res: WGroup, action_res: WAction, change_selected_body: bool, new_data: Dictionary, body = null):
	var new_blank_body
	if !change_selected_body:
		if !body:
			new_blank_body = load("res://addons/event_sheet/elements/Blank Body/blank_body.tscn").instantiate()
			new_blank_body.add_action_button.connect(_on_add_action_button_clicked)
			new_blank_body.bb_popup_button.connect(_on_blank_body_clicked)
			blank_body_items.add_child(new_blank_body)
		else:
			new_blank_body = body
		
		var new_action = load("res://addons/event_sheet/elements/Action/action.tscn").instantiate()
		new_action.group_resource = group_res
		new_action.action_resource = action_res
		if new_data.size() > 0: new_action.new_data = new_data
		new_action.action_clicked.connect(_on_action_clicked)
		new_action.blank_body = new_blank_body
		
		new_blank_body.actions_tree.add_child(new_action)
		new_blank_body.actions_tree.move_child(new_action, new_blank_body.actions_tree.get_child_count() - 2)
		new_blank_body.actions.append(new_action)
	else:
		if current_blank_body:
			var new_action = load("res://addons/event_sheet/elements/Action/action.tscn").instantiate()
			new_action.group_resource = group_res
			new_action.action_resource = action_res
			if new_data.size() > 0: new_action.new_data = new_data
			new_action.action_clicked.connect(_on_action_clicked)
			new_action.blank_body = current_blank_body
			
			current_blank_body.actions_tree.add_child(new_action)
			current_blank_body.actions_tree.move_child(new_action, current_blank_body.actions_tree.get_child_count() - 2)
			current_blank_body.actions.append(new_action)
		else:
			add_action(group_res, action_res, false, new_data)

func delete_blank_body(blank_body):
	blank_body.actions.clear()
	blank_body.events.clear()
	current_blank_body = null
	blank_body.queue_free()

func delete_event(blank_body, event):
	blank_body.events.erase(event)
	current_event = null
	event.queue_free()

func delete_action(blank_body, action):
	blank_body.actions.erase(action)
	current_action = null
	action.queue_free()

func show_popup_menu(menu: String = "general"):
	current_menu = menu
	var mouse_pos = Vector2i(get_viewport().get_mouse_position()) + get_window().position
	popup_menu.clear()
	for item in popup_menus[menu]:
		if item == "": popup_menu.add_separator()
		else: popup_menu.add_item(item)
	popup_menu.set_size(Vector2(0, 0))
	popup_menu.set_position(mouse_pos)
	popup_menu.show()

func select_blank_body():
	if current_blank_body:
		for blank_body in blank_body_items.get_children():
			blank_body.set_selected(false)
		current_blank_body.set_selected(true)

func _on_mouse_entered() -> void: is_mouse_focused = true

func _on_mouse_exited() -> void: is_mouse_focused = false

func _on_add_action_button_clicked(blank_body) -> void:
	current_blank_body = blank_body
	select_blank_body()
	show_add_window("action", true)

func _on_event_clicked(blank_body, event, index: int, button: int) -> void:
	match button:
		MOUSE_BUTTON_RIGHT:
			show_popup_menu("event")
			current_blank_body = blank_body
			current_event = event
			select_blank_body()
		MOUSE_BUTTON_LEFT:
			current_blank_body = blank_body
			current_event = event
			select_blank_body()

func _on_action_clicked(blank_body, action, index: int, button: int) -> void:
	match button:
		MOUSE_BUTTON_RIGHT:
			show_popup_menu("action")
			current_blank_body = blank_body
			current_action = action
			select_blank_body()
		MOUSE_BUTTON_LEFT:
			current_blank_body = blank_body
			current_action = action
			select_blank_body()

func _on_blank_body_clicked(blank_body, index: int, button: int) -> void:
	match button:
		MOUSE_BUTTON_RIGHT:
			show_popup_menu("blank_body")
			current_blank_body = blank_body
			select_blank_body()
		MOUSE_BUTTON_LEFT:
			current_blank_body = blank_body
			select_blank_body()

func _on_popup_menu_index_pressed(index: int) -> void:
	if current_menu == "general":
		match index:
			0: add_blank_body()
	elif current_menu == "blank_body" and current_blank_body:
		match index:
			0: show_add_window("event", true)
			1: show_add_window("action", true)
			3: delete_blank_body(current_blank_body)
	elif current_menu == "event" and current_blank_body:
		match index:
			0: pass
			1: show_add_window("event", true)
			3: delete_event(current_blank_body, current_event)
	elif current_menu == "action" and current_blank_body:
		match index:
			0: pass
			1: show_add_window("action", true)
			3: delete_action(current_blank_body, current_action)

# # # # # # # # # # #
# Add Event Window #
# # # # # # # # # #
func _on_add_window_close_requested() -> void:
	window_add.hide()

func _on_add_event_or_action_close_requested() -> void:
	window_add_event_or_action.hide()

func _on_set_parameter_close_requested() -> void:
	window_set_parametr.hide()

func show_add_window(type: String = "event", change_selected_body: bool = true):
	var items: GridContainer = $AddWindow/Panel/MarginContainer/ScrollContainer/Items
	var res_groups_path: String = "res://addons/event_sheet/plugins/groups/"
	var res_groups: Array[WGroup] = []
	var dir := DirAccess.open(res_groups_path)
	
	for item in items.get_children(): item.queue_free()
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Пропускаем директории
			if dir.current_is_dir() == false:
				var resource_path = res_groups_path + file_name
				if resource_path.ends_with(".tres") or resource_path.ends_with(".res"):
					var resource = ResourceLoader.load(resource_path)
					if resource: res_groups.append(resource)
			file_name = dir.get_next()
		dir.list_dir_end()
	else: print("Failed to open directory: ", res_groups_path)
	
	for res: WGroup in res_groups:
		var id: String = res.id
		var title: String = res.title
		var icon: Texture2D = res.icon
		var events: Array = res.events
		var actions: Array = res.actions
		
		match id:
			"system":
				var button: Button = Button.new()
				button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
				button.clip_text = true
				button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
				button.expand_icon = true
				button.custom_minimum_size = Vector2i(96, 96)
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				match type:
					"event":
						window_add.title = "Add Event"
						if events.size() > 0:
							button.text = title
							button.icon = icon
							button.gui_input.connect(_on_add_gui_input.bind(type, events, res, change_selected_body))
							items.add_child(button)
					"action":
						window_add.title = "Add Action"
						if actions.size() > 0:
							button.text = title
							button.icon = icon
							button.gui_input.connect(_on_add_gui_input.bind(type, actions, res, change_selected_body))
							items.add_child(button)
	
	window_add.position = (get_window().size / 2) - (window_add.size / 2)
	window_add.show()

func _on_add_gui_input(event: InputEvent, type: String, items: Array, group_resource: WGroup, change_selected_body: bool) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		window_add.hide()
		
		var items_box: VBoxContainer = $AddEventOrAction/Panel/MarginContainer/ScrollContainer/VBoxContainer
		
		for item in items_box.get_children(): item.queue_free()
		
		var group_name: Label = Label.new()
		group_name.text = "test"
		group_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		group_name.clip_text = true
		group_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_CHAR
		var group_items: GridContainer = GridContainer.new()
		group_items.columns = 2
		group_items.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		var group_separator: HSeparator = HSeparator.new()
		
		match type:
			"event":
				for _event: WEvent in items:
					var id: String = _event.id
					var title: String = _event.title
					var icon: Texture2D = _event.icon
					var description: String = _event.description
					var parameters: Dictionary = _event.parameters
					var group: String = _event.group
					
					var button: Button = Button.new()
					button.alignment = HORIZONTAL_ALIGNMENT_LEFT
					button.clip_text = true
					button.expand_icon = true
					button.custom_minimum_size = Vector2i(243, 40)
					button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					button.gui_input.connect(_on_add_event_or_action_gui_input.bind(_event, group_resource, change_selected_body))
					button.text = _event.title
					button.icon = _event.icon
					
					group_items.add_child(button)
			"action":
				for _action: WAction in items:
					var id: String = _action.id
					var title: String = _action.title
					var icon: Texture2D = _action.icon
					var description: String = _action.description
					var parameters: Dictionary = _action.parameters
					var group: String = _action.group

					var button: Button = Button.new()
					button.alignment = HORIZONTAL_ALIGNMENT_LEFT
					button.clip_text = true
					button.expand_icon = true
					button.custom_minimum_size = Vector2i(243, 40)
					button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					button.gui_input.connect(_on_add_event_or_action_gui_input.bind(_action, group_resource, change_selected_body))
					button.text = title
					button.icon = icon
					
					group_items.add_child(button)
		
		items_box.add_child(group_name)
		items_box.add_child(group_items)
		items_box.add_child(group_separator)

		window_add_event_or_action.position = (get_window().size / 2) - (window_add_event_or_action.size / 2)
		window_add_event_or_action.show()

func _on_add_event_or_action_gui_input(event: InputEvent, object_resource, group_resource: WGroup, change_selected_body: bool) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		window_add_event_or_action.hide()
		
		var description_label: Label = $SetParameter/Panel/MarginContainer/VBoxContainer/Description
		var parameters_box: VBoxContainer = $SetParameter/Panel/MarginContainer/VBoxContainer/ScrollContainer/Parameters
		var back_button: Button = $SetParameter/Panel/MarginContainer/VBoxContainer/Buttons/Back
		var finish_button: Button = $SetParameter/Panel/MarginContainer/VBoxContainer/Buttons/Finish
		
		if object_resource is WEvent:
			var event_resource: WEvent = object_resource
			if event_resource.parameters.size() > 0:
				for item in parameters_box.get_children(): item.queue_free()
				
				description_label.text = "{0}: {1}".format([event_resource.title, event_resource.description])
				for key in event_resource.parameters:
					var value = event_resource.parameters[key]
					
					var parameter: HBoxContainer = HBoxContainer.new()
					parameter.name = "Param"
					parameter.size_flags_vertical = Control.SIZE_SHRINK_BEGIN | Control.SIZE_EXPAND
					var param_name: Label = Label.new()
					param_name.name = "Name"
					param_name.text = str(key)
					param_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
					param_name.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN | Control.SIZE_EXPAND
					param_name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
					param_name.size_flags_stretch_ratio = 0
					parameter.add_child(param_name)
					
					if value is int:
						var param_input: LineEdit = LineEdit.new()
						param_input.name = "IntValue"
						param_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						param_input.text = str(value)
						parameter.add_child(param_input)
					elif value is float:
						var param_input: LineEdit = LineEdit.new()
						param_input.name = "FloatValue"
						param_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						param_input.text = str(value)
						parameter.add_child(param_input)
					elif value is String:
						var param_input: LineEdit = LineEdit.new()
						param_input.name = "StringValue"
						param_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						param_input.text = str(value)
						parameter.add_child(param_input)
					elif value is NodePath:
						var param_input: LineEdit = LineEdit.new()
						param_input.name = "NodePathValue"
						param_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						param_input.text = str(value)
						parameter.add_child(param_input)
					else:
						var param_input: LineEdit = LineEdit.new()
						param_input.name = "_Value"
						param_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						param_input.text = str(value)
						parameter.add_child(param_input)
					
					parameters_box.add_child(parameter)
				
				if !back_button.button_up.is_connected(_on_back_button_up):
					back_button.button_up.connect(_on_back_button_up)
				if !finish_button.button_up.is_connected(_on_finish_button_up):
					finish_button.button_up.connect(_on_finish_button_up.bind("event", parameters_box, group_resource, event_resource, change_selected_body))
				window_set_parametr.position = (get_window().size / 2) - (window_set_parametr.size / 2)
				window_set_parametr.show()
			else:
				var new_data = {}
				add_event(group_resource, event_resource, change_selected_body, new_data)
		elif object_resource is WAction:
			var action_resource: WAction = object_resource
			if action_resource.parameters.size() > 0:
				for item in parameters_box.get_children(): item.queue_free()
				
				description_label.text = "{0}: {1}".format([action_resource.title, action_resource.description])
				for key in action_resource.parameters:
					var value = action_resource.parameters[key]
					
					var parameter: HBoxContainer = HBoxContainer.new()
					parameter.name = "Param"
					parameter.size_flags_vertical = Control.SIZE_SHRINK_BEGIN | Control.SIZE_EXPAND
					var param_name: Label = Label.new()
					param_name.name = "Name"
					param_name.text = str(key)
					param_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
					param_name.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN | Control.SIZE_EXPAND
					param_name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
					param_name.size_flags_stretch_ratio = 0
					parameter.add_child(param_name)
					
					if value is int:
						var param_input: LineEdit = LineEdit.new()
						param_input.name = "IntValue"
						param_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						param_input.text = str(value)
						parameter.add_child(param_input)
					elif value is String:
						var param_input: LineEdit = LineEdit.new()
						param_input.name = "StringValue"
						param_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						param_input.text = str(value)
						parameter.add_child(param_input)
					elif value is NodePath:
						var param_input: LineEdit = LineEdit.new()
						param_input.name = "NodePathValue"
						param_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						param_input.text = str(value)
						parameter.add_child(param_input)
					else:
						var param_input: LineEdit = LineEdit.new()
						param_input.name = "_Value"
						param_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						param_input.text = str(value)
						parameter.add_child(param_input)
					
					parameters_box.add_child(parameter)
				
				if !back_button.button_up.is_connected(_on_back_button_up):
					back_button.button_up.connect(_on_back_button_up)
				if !finish_button.button_up.is_connected(_on_finish_button_up):
					finish_button.button_up.connect(_on_finish_button_up.bind("action", parameters_box, group_resource, action_resource, change_selected_body))
				window_set_parametr.position = (get_window().size / 2) - (window_set_parametr.size / 2)
				window_set_parametr.show()
			else:
				var new_data = {}
				add_action(group_resource, action_resource, change_selected_body, new_data)

func _on_finish_button_up(type: String, parameters_box: VBoxContainer, group_resource: WGroup, resource, change_selected_body: bool) -> void:
	
	var new_data: Dictionary = {}
	
	for param: HBoxContainer in parameters_box.get_children():
		var p_name: Label = param.get_child(0)
		var p_value = param.get_child(1)
		if p_value is LineEdit: new_data[p_name.text] = p_value.text
	
	match type:
		"event":
			add_event(group_resource, resource, change_selected_body, new_data)
		"action":
			add_action(group_resource, resource, change_selected_body, new_data)
	
	window_set_parametr.hide()

func _on_back_button_up() -> void:
	window_set_parametr.hide()
	window_add_event_or_action.show()
