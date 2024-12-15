extends Node

# This will hold the global condition value
var isNight = false

# Static instance of the GlobalManager
static var instance = null

# On instance creation, make it the singleton
func _init():
	if instance:
		return
	instance = self

# Accessor to retrieve the global condition
func get_global_condition():
	print(isNight)
	return isNight
