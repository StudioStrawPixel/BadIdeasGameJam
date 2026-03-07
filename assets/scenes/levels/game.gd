extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start("timeline")
	var layout = Dialogic.start("timeline")
	layout.register_character(load("res://Dialogue/glorb.dch"), $Player/bubble)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
