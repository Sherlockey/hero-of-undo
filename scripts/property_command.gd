class_name PropertyCommand
extends Command

var _object: Object
var _property: StringName
var _value: Variant


func _init(object: Object, property: StringName, value: Variant) -> void:
	_object = object
	_property = property
	_value = value


func undo() -> void:
	_object.set(_property, _value)
