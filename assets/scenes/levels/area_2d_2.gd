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
	start_notyet_dialogue(body)

func start_notyet_dialogue(player_node: Node) -> void:
	player_node.start_dialogue()
	var layout = Dialogic.start("notyet")
	add_child(layout)
	layout.register_character(load("res://Dialogue/farquid.dch"), player_node.get_node("farquidcharacter/farquidbubble"))
	layout.register_character(load("res://Dialogue/unknown.dch"), player_node.get_node("farquidcharacter/farquidbubble"))
	layout.register_character(load("res://Dialogue/glorb.dch"), player_node.get_node("bubble"))
	await Dialogic.timeline_ended
	player_node.end_dialogue()

	get_tree().change_scene_to_file("res://assets/scenes/main_menu.tscn")
