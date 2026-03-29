extends Control

@export var tutorial_text: String = "Default tutorial text"
@onready var label: Label = $Panel/Label
@onready var button: Button = $Panel/Button

signal tutorial_finished

func _ready():
	pause_mode = 2  # PROCESS mode
	label.text = tutorial_text

	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(_on_continue_pressed)

	$Panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var panel_size = $Panel.size
	global_position = get_viewport_rect().size / 2 - panel_size / 2

func _on_continue_pressed():
	emit_signal("tutorial_finished")
	queue_free()
