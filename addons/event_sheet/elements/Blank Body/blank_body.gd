@tool
extends MarginContainer

@onready var hSplitContainer: HSplitContainer = $HSplitContainer
@onready var blank_body_tree: VBoxContainer = $HSplitContainer/Event/VBoxContainer
@onready var actions_tree: VBoxContainer = $HSplitContainer/Action/VBoxContainer
@onready var selected_panel: Panel = $Selected

signal add_action_button(blank_body)
signal bb_popup_button(blank_body, index: int, button: int)

var last_y_size: int = 0
var events: Array
var actions: Array

func _ready() -> void:
	last_y_size = hSplitContainer.size.y

func _process(delta: float) -> void:
	if last_y_size != hSplitContainer.size.y:
		custom_minimum_size.y = hSplitContainer.size.y
		size.y = hSplitContainer.size.y
		last_y_size = hSplitContainer.size.y

func set_selected(selected: bool):
	selected_panel.visible = selected

func _on_add_action_button_up() -> void:
	add_action_button.emit(self)

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		bb_popup_button.emit(self, get_index(), event.button_index)

func _on_h_split_container_dragged(offset: int) -> void:
	for split: HSplitContainer in get_tree().get_nodes_in_group("blank_body_split"):
		split.split_offset = offset

func _save() -> Dictionary:
	var events_data: Dictionary = {}
	var actions_data: Dictionary = {}
	
	for i in events.size():
		var event = events[i]
		events_data[i] = event.get_save_data()
	
	for i in actions.size():
		var action = actions[i]
		actions_data[i] = action.get_save_data()
	
	var data: Dictionary = {
		"events": events_data,
		"actions": actions_data,
	}
	
	return data
