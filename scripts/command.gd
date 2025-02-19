class_name Command
extends RefCounted

signal finished

var does_consume_process: bool = false
var _does_await: bool = false
var _data: Dictionary = {}


func execute() -> void:
	pass


func undo() -> void:
	pass
