extends CharacterBody2D

enum STATE {
	FALL,
	FLOOR,
	JUMP,
	DOUBLE_JUMP,
	FLOAT,
	LEDGE_CLIMB,
	LEDGE_JUMP,
	WALL_SLIDE,
	WALL_JUMP,
	WALL_CLIMB,
	DASH,
	TURNING
}

const FALL_GRAVITY := 3500.0
const FALL_VELOCITY := 2500.0
const WALK_VELOCITY := 1000.0
const JUMP_VELOCITY := -2000.0
const JUMP_DECELERATION := 3500.0
const DOUBLE_JUMP_VELOCITY := -1600.0
const FLOAT_GRAVITY := 2200.0
const FLOAT_VELOCITY := 2100.0
const FLOAT_ACCELERATION := 2700.0
const LEDGE_JUMP_VELOCITY := -2500.0
const WALL_SLIDE_GRAVITY := 2300.0
const WALL_SLIDE_VELOCITY := 2500.0
const WALL_JUMP_LENGTH := 300.0
const WALL_JUMP_VELOCITY := -1000.0
const WALL_CLIMB_VELOCITY := -2300.0
const WALL_CLIMB_LENGTH := 65.0
const DASH_LENGTH := 1000.0
const DASH_VELOCITY := 1600.0
const SPRINT_VELOCITY := 1400.0
const SPRINT_ACCELERATION := 3800.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var float_cooldown: Timer = $FloatCooldown
@onready var player_collider: CollisionShape2D = $PlayerCollider
@onready var ledge_climb_ray_cast: RayCast2D = $LedgeClimbRayCast
@onready var ledge_space_ray_cast: RayCast2D = $LedgeSpaceRayCast
@onready var wall_slide_ray_cast: RayCast2D = $WallSlideRayCast
@onready var dash_cooldown: Timer = $DashCooldown
@onready var gun: Sprite2D = $Gun
@onready var camera_2d: Camera2D = $CameraOffset/Camera2D
@onready var footstep_audio: AudioStreamPlayer2D = $Footsteps

var active_state := STATE.FALL
var can_double_jump := false
var facing_direction := 1.0
var saved_position := Vector2.ZERO
var can_dash := false
var dash_jump_buffer := false
var is_sprinting := false
var is_gun_equipped := false
var was_gun_equipped_before_restricted := false
var in_dialogue := false
var gun_locked := false
var is_equipping_gun := false
var is_slide_locked := false
var slide_lock_timer: Timer
var gun_show_timer: Timer
var gun_unlocked: bool = false
var can_play_footsteps: bool = false

func _ready() -> void:
	switch_state(active_state)
	ledge_climb_ray_cast.add_exception(self)
	if gun:
		gun.visible = false
		gun.call("unequip")
	slide_lock_timer = Timer.new()
	slide_lock_timer.one_shot = true
	slide_lock_timer.wait_time = 0.2
	slide_lock_timer.timeout.connect(_on_slide_lock_end)
	add_child(slide_lock_timer)
	gun_show_timer = Timer.new()
	gun_show_timer.one_shot = true
	gun_show_timer.wait_time = 0.5
	gun_show_timer.timeout.connect(_show_gun_after_delay)
	add_child(gun_show_timer)
	set_camera_limits()
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if in_dialogue:
		velocity.x = 0
		velocity.y = move_toward(velocity.y, FALL_VELOCITY, FALL_GRAVITY * delta)
		move_and_slide()
		return
	if is_equipping_gun:
		velocity.y = move_toward(velocity.y, FALL_VELOCITY, FALL_GRAVITY * delta)
		velocity.x = 0
		move_and_slide()
		return
	if is_slide_locked:
		velocity.x = move_toward(velocity.x, 0, 8000 * delta)
		velocity.y = move_toward(velocity.y, FALL_VELOCITY, FALL_GRAVITY * delta)
		move_and_slide()
		return
	process_state(delta)
	move_and_slide()

func process_state(delta: float) -> void:
	if is_slide_locked:
		velocity.x = move_toward(velocity.x, 0, 8000 * delta)
		return
	match active_state:
		STATE.FALL:
			velocity.y = move_toward(velocity.y, FALL_VELOCITY, FALL_GRAVITY * delta)
			if Input.is_action_pressed("sprint") and not is_on_wall():
				handle_sprint(delta)
			else:
				handle_movement()
			if is_on_floor():
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_pressed("jump"):
				if coyote_timer.time_left > 0:
					switch_state(STATE.JUMP)
				elif can_double_jump:
					switch_state(STATE.DOUBLE_JUMP)
				else:
					switch_state(STATE.FLOAT)
		STATE.FLOOR:
			if Input.is_action_pressed("sprint") and not is_on_wall():
				animated_sprite.play("sprint")
				handle_sprint(delta)
			else:
				if Input.get_axis("move_left", "move_right") != 0:
					animated_sprite.play("walk")
				else:
					animated_sprite.play("idle")
				handle_movement()
			if not is_on_floor():
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("jump"):
				switch_state(STATE.JUMP)
		STATE.JUMP, STATE.DOUBLE_JUMP:
			velocity.y = move_toward(velocity.y, 0, JUMP_DECELERATION * delta)
			if Input.is_action_pressed("sprint") and not is_on_wall():
				handle_sprint(delta)
			else:
				handle_movement()
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				switch_state(STATE.FALL)
		STATE.FLOAT:
			velocity.y = move_toward(velocity.y, FLOAT_VELOCITY, FLOAT_GRAVITY * delta)
			handle_movement(0, WALK_VELOCITY, FLOAT_ACCELERATION * delta)
			if is_on_floor():
				switch_state(STATE.FLOOR)
		STATE.DASH:
			velocity.y = move_toward(velocity.y, FALL_VELOCITY, FALL_GRAVITY * delta)
			handle_sprint(delta)
			if is_on_floor():
				coyote_timer.start()
			var distance: float = abs(position.x - saved_position.x)
			if distance >= DASH_LENGTH:
				switch_state(STATE.FALL)

func switch_state(to_state: STATE) -> void:
	if is_equipping_gun and to_state in [STATE.JUMP, STATE.DOUBLE_JUMP, STATE.FLOAT, STATE.DASH, STATE.FALL, STATE.FLOOR]:
		return
	var previous_state := active_state
	active_state = to_state
	match active_state:
		STATE.FALL:
			if previous_state != STATE.DOUBLE_JUMP:
				animated_sprite.play("fall")
			if previous_state == STATE.FLOOR:
				coyote_timer.start()
		STATE.FLOOR:
			can_double_jump = true
			can_dash = true
		STATE.JUMP:
			if previous_state != STATE.TURNING:
				animated_sprite.play("jump")
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
		STATE.DOUBLE_JUMP:
			animated_sprite.play("double_jump")
			velocity.y = DOUBLE_JUMP_VELOCITY
			can_double_jump = false
			is_sprinting = false
		STATE.FLOAT:
			if float_cooldown.time_left > 0:
				active_state = previous_state
				return
			animated_sprite.play("float")
			velocity.y = 0
			is_sprinting = false
		STATE.DASH:
			if dash_cooldown.time_left > 0:
				active_state = previous_state
				return
			animated_sprite.play("dash")
			velocity.y = 0
			set_facing_direction(signf(Input.get_axis("move_left", "move_right")))
			velocity.x = facing_direction * DASH_VELOCITY
			saved_position = position
			can_dash = previous_state in [STATE.FLOOR, STATE.WALL_SLIDE]
			dash_jump_buffer = false

func handle_movement(input_direction: float = 0, horizontal_velocity: float = WALK_VELOCITY, step: float = WALK_VELOCITY) -> void:
	if is_slide_locked or in_dialogue:
		return
	if input_direction == 0:
		input_direction = signf(Input.get_axis("move_left", "move_right"))
	var target_velocity = input_direction * horizontal_velocity
	velocity.x = move_toward(velocity.x, target_velocity, step)
	if input_direction != 0:
		set_facing_direction(input_direction)
		if can_play_footsteps and not footstep_audio.playing and is_on_floor():
			footstep_audio.play()
	else:
		if footstep_audio.playing:
			footstep_audio.stop()

func handle_sprint(delta: float) -> void:
	var input_dir = signf(Input.get_axis("move_left", "move_right"))
	if input_dir != 0:
		set_facing_direction(input_dir)
		velocity.x = move_toward(velocity.x, input_dir * SPRINT_VELOCITY, SPRINT_ACCELERATION * delta)
		if can_play_footsteps and not footstep_audio.playing and is_on_floor():
			footstep_audio.pitch_scale = 1.5
			footstep_audio.play()
	else:
		if footstep_audio.playing:
			footstep_audio.stop()
	is_sprinting = Input.is_action_pressed("sprint") and not is_on_wall()

func set_facing_direction(direction: float) -> void:
	if direction != 0:
		facing_direction = direction
		ledge_climb_ray_cast.position.x = direction * abs(ledge_climb_ray_cast.position.x)
		ledge_climb_ray_cast.target_position.x = direction * abs(ledge_climb_ray_cast.target_position.x)
		ledge_climb_ray_cast.force_raycast_update()
		wall_slide_ray_cast.position.x = direction * abs(wall_slide_ray_cast.position.x)
		wall_slide_ray_cast.target_position.x = direction * abs(wall_slide_ray_cast.target_position.x)
		wall_slide_ray_cast.force_raycast_update()

func toggle_gun():
	if in_dialogue or gun_locked or not gun_unlocked:
		return
	if is_gun_equipped:
		unequip_gun()
	else:
		equip_gun()

func equip_gun() -> void:
	if in_dialogue or gun_locked:
		return
	if gun:
		gun.visible = false
		gun.call("equip")
	is_slide_locked = true
	slide_lock_timer.start()
	is_gun_equipped = true
	is_equipping_gun = true
	animated_sprite.play("gun_equip")
	gun_show_timer.start()

func _show_gun_after_delay() -> void:
	if gun and is_gun_equipped and not gun_locked:
		gun.reveal()

func unequip_gun() -> void:
	if gun:
		gun.call("unequip")
		gun.visible = false
	is_gun_equipped = false
	is_equipping_gun = false
	animated_sprite.play("idle")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "gun_equip":
		animated_sprite.stop()
		animated_sprite.frame = 1
		is_equipping_gun = false

func _on_slide_lock_end():
	is_slide_locked = false

func can_player_shoot() -> bool:
	return is_gun_equipped and not gun_locked and active_state not in [STATE.WALL_SLIDE, STATE.LEDGE_CLIMB, STATE.LEDGE_JUMP, STATE.WALL_CLIMB, STATE.FLOAT]

func _process(delta: float) -> void:
	if gun_locked:
		if gun:
			gun.visible = false
		is_gun_equipped = false
		return
	if is_equipping_gun:
		var mouse_global_pos = get_global_mouse_position()
		var flip = mouse_global_pos.x < global_position.x
		animated_sprite.flip_h = flip
		gun.position.x = abs(gun.position.x) * (-1 if flip else 1)
		gun.rotation_degrees = 180 if flip else 0
		return
	if is_gun_equipped:
		animated_sprite.flip_h = facing_direction < 0
		var flip = facing_direction < 0
		gun.position.x = abs(gun.position.x) * (-1 if flip else 1)
		gun.rotation_degrees = 180 if flip else 0
	else:
		animated_sprite.flip_h = facing_direction < 0
	if gun:
		var restricted := active_state in [STATE.WALL_SLIDE, STATE.LEDGE_CLIMB, STATE.LEDGE_JUMP, STATE.WALL_CLIMB, STATE.FLOAT]
		if restricted and is_gun_equipped:
			was_gun_equipped_before_restricted = true
			unequip_gun()
		elif was_gun_equipped_before_restricted:
			equip_gun()
			was_gun_equipped_before_restricted = false

func _input(event):
	if in_dialogue or gun_locked or not gun_unlocked:
		return
	if event.is_action_pressed("toggle_gun"):
		toggle_gun()

func set_camera_limits(limits_node: Node = null):
	if not limits_node:
		limits_node = get_tree().current_scene.get_node_or_null("CameraLimits")
	if camera_2d and limits_node:
		camera_2d.make_current()
		camera_2d.limit_left = limits_node.left_limit
		camera_2d.limit_right = limits_node.right_limit
		camera_2d.limit_top = limits_node.top_limit
		camera_2d.limit_bottom = limits_node.bottom_limit

func start_dialogue():
	in_dialogue = true
	gun_locked = true
	velocity.x = 0
	is_slide_locked = true
	if is_gun_equipped:
		unequip_gun()
	if gun:
		gun.visible = false
	animated_sprite.play("idle")

func end_dialogue():
	in_dialogue = false
	gun_locked = false
	is_slide_locked = false
	animated_sprite.play("idle")
