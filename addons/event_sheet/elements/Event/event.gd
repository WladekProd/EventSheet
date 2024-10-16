@tool
extends WObject

@onready var icon_texture: TextureRect = $MarginContainer/HBoxContainer/Icon
@onready var group_label: Label = $MarginContainer/HBoxContainer/HSplitContainer/Name
@onready var event_label: Label = $MarginContainer/HBoxContainer/HSplitContainer/Event

signal event_clicked(blank_body, event, index: int, button: int)
@export var event_resource: WEvent

func _ready() -> void:
	init_object(event_resource, icon_texture, group_label, event_label)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		event_clicked.emit(blank_body, self, get_index(), event.button_index)

func _on_h_split_container_dragged(offset: int) -> void:
	for split: HSplitContainer in get_tree().get_nodes_in_group("event_split"):
		split.split_offset = offset

func get_save_data() -> Dictionary:
	var data: Dictionary = _save(event_resource)
	return data
