extends Node2D

@onready var animation_player: AnimationPlayer = $Human/AnimationPlayer
@onready var player: Node = $Player
@onready var humanbubble: Marker2D = $Human/humanbubble

func _ready() -> void:
	if player:
		player.start_dialogue()
		var bubble_node = player.get_node_or_null("bubble")
		if bubble_node:
			var layout = Dialogic.start("startgame")
			layout.register_character(load("res://Dialogue/glorb.dch"), bubble_node)
		await Dialogic.timeline_ended
		
		animation_player.play("humanwalkout")
		await animation_player.animation_finished
		
		if bubble_node:
			var layout2 = Dialogic.start("startgame2")
			layout2.register_character(load("res://Dialogue/glorb.dch"), bubble_node)
		await Dialogic.timeline_ended
		
		player.start_dialogue()
		animation_player.play("glorphide")
		await animation_player.animation_finished
		
		if humanbubble:
			var layout3 = Dialogic.start("humanbox")
			layout3.register_character(load("res://Dialogue/human.dch"), humanbubble)
		await Dialogic.timeline_ended

		animation_player.play("humanend")
		await animation_player.animation_finished
		
		if bubble_node:
			var layout = Dialogic.start("humanendtimeline")
			layout.register_character(load("res://Dialogue/glorb.dch"), bubble_node)
		await Dialogic.timeline_ended
		
		player.end_dialogue()
