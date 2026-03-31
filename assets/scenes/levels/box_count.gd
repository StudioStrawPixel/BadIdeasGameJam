extends Node2D

var flower_count := 0
signal flower_changed(new_count)

func add_flower():
	flower_count += 1
	emit_signal("flower_changed", flower_count)
