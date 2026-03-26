extends Node2D


func _ready():
	await get_tree().process_frame
	$Fade.fade(0.0, 1.5)
