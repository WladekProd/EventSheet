@tool
extends EditorPlugin

const EventSheet = preload("res://addons/event_sheet/elements/EventSheet/event_sheet.tscn")
var event_sheet_instance

const PLUGIN_PATH := "plugins/event_sheet/shortcut"
var shortcut_res: Shortcut = preload("res://addons/event_sheet/default_shortcut.tres")
var shortcut: Shortcut

func _enter_tree():
	add_autoload_singleton("WES", "res://addons/event_sheet/scripts/autoload.gd")
	shortcut = set_shortcut(PLUGIN_PATH, shortcut_res)
	event_sheet_instance = EventSheet.instantiate()
	EditorInterface.get_editor_main_screen().add_child(event_sheet_instance)
	_make_visible(false)

func _exit_tree():
	remove_autoload_singleton("WES")
	shortcut = null
	EditorInterface.get_editor_settings().erase(PLUGIN_PATH)
	if event_sheet_instance:
		event_sheet_instance.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if event_sheet_instance:
		event_sheet_instance.visible = visible

func _get_plugin_name():
	return "EventSheet"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Favorites", "EditorIcons")

func set_shortcut(project_setting_path: String, resource: Shortcut) -> Shortcut:
	EditorInterface.get_editor_settings().set_setting(PLUGIN_PATH, resource)
	return resource
