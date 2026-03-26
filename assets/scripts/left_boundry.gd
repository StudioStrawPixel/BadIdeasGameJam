extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.start_dialogue()

		var layout = Dialogic.start("left bounds")
		layout.register_character(load("res://Dialogue/glorb.dch"), $"../Player/bubble")

		Dialogic.timeline_ended.connect(body.end_dialogue)
