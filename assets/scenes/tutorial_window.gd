extends Control

@export var tutorial_text: String = "Default tutorial text"
@onready var panel: Panel = $Panel
@onready var label: Label = $Panel/Label
@onready var button: Button = $Panel/Button

signal tutorial_finished

func _ready():
	top_level = true
	z_index = 99999
	set_z_as_relative(false)
	label.text = tutorial_text
	button.pressed.connect(_on_continue_pressed)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_center_panel()
	visible = false

func _center_panel():
	if panel:
		var panel_size: Vector2 = panel.get_size()
		global_position = get_viewport_rect().size / 2 - panel_size / 2

func show_tutorial(text: String = ""):
	if text != "":
		label.text = text
	_center_panel()
	visible = true
	button.grab_focus()

func _on_continue_pressed():
	emit_signal("tutorial_finished")
	queue_free()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_center_panel()
