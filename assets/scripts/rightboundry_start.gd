extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		await $"../Fade".fade(1.0, 1.5).finished
		get_tree().change_scene_to_file("res://assets/scenes/levels/monet.tscn")
		
		
