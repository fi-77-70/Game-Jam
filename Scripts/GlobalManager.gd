extends Node

# This will hold the global condition value
var isNight = false

# Static instance of the GlobalManager
static var instance = null

var isRenderInit = false

# On instance creation, make it the singleton
func _init():
	if instance:
		return
	instance = self

func _ready():
	if !isRenderInit:
		print (isRenderInit)
		isRenderInit = true
		for node in get_tree().get_nodes_in_group("render"):
			node.visible = false

# Accessor to retrieve the global condition
func get_global_condition():
	print(isNight)
	return isNight
