extends Label

@onready var boxes_node: Node = $"../../Boxes"

func _ready():
	if boxes_node:
		boxes_node.connect("flower_changed", Callable(self, "_on_flower_changed"))
		text = str(boxes_node.flower_count)
	visible = true

func _on_flower_changed(new_count):
	text = str(new_count)
