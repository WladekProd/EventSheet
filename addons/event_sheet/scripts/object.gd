extends Button
class_name WObject

@export var group_resource: WGroup
@export var new_data: Dictionary = {}
var blank_body

func init_object(resource, icon_texture: TextureRect, group_label: Label, label: Label) -> void:
	if group_resource and resource:
		icon_texture.texture = group_resource.icon
		group_label.text = group_resource.title
		if resource.parameters.size() > 0:
			label.text = "{0}: ".format([resource.title])
			var i = 1
			for key in resource.parameters:
				var value = resource.parameters[key]
				var new_value = new_data[key]
				
				if value is int:
					label.text += "{0} - {1}".format([str(key), str(new_value)])
				elif value is String:
					label.text += "{0} - {1}".format([str(key), str(new_value)])
				elif value is NodePath:
					label.text += "{0} - {1}".format([str(key), str(new_value)])
				else:
					label.text += "{0} - {1}".format([str(key), str(new_value)])

				if i < resource.parameters.size():
					label.text += ", "
				i += 1
		else:
			label.text = "{0}".format([resource.title])

func _save(resource: Resource) -> Dictionary:
	var data: Dictionary = {
		"group_resource_path": group_resource.resource_path,
		"resource_path": resource.resource_path,
		"new_parametrs": new_data
	}
	return data
