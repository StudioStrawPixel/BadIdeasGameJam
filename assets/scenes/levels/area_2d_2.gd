extends Area2D

var triggered := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if triggered:
		return
	if body.name != "Player":
		return
	triggered = true

	get_tree().change_scene_to_file("res://assets/scenes/levels/birds.tscn")
