extends CharacterBody2D

enum STATE {
	FALL,
	FLOOR,
	JUMP,
	DOUBLE_JUMP,
	FLOAT,
	LEDGE_CLIMB,
	LEDGE_JUMP,
	DASH
}


const FALL_GRAVITY := 1500.0
const FALL_VELOCITY := 500.0
const WALK_VELOCITY := 200.0
const JUMP_VELOCITY := -600.0
const JUMP_DECELERATION := 1500.0
const DOUBLE_JUMP_VELOCITY := -450.0
const FLOAT_GRAVITY := 200.0
const FLOAT_VELOCITY := 100.0
const LEDGE_JUMP_VELOCITY := -500.0
const DASH_LENGTH := 100.0
const DASH_VELOCITY := 600.0
const SPRINT_VELOCITY := 400.0
const SPRINT_ACCELERATION := 1800.0

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var float_cooldown: Timer = %FloatCooldown
@onready var player_collider: CollisionShape2D = %PlayerCollider
@onready var ledge_climb_ray_cast: RayCast2D = %LedgeClimbRayCast
@onready var ledge_space_ray_cast: RayCast2D = %LedgeSpaceRayCast
@onready var dash_cooldown: Timer = %DashCooldown



var active_state := STATE.FALL
var can_double_jump := false
var facing_direction := 1.0
var can_dash := false
var dash_jump_buffer := false
var saved_position := Vector2.ZERO
var is_sprinting := false

func _ready() -> void:
	switch_state(active_state)
	ledge_climb_ray_cast.add_exception(self)


func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()
	
func switch_state(to_state: STATE) -> void:
	var previous_state := active_state
	active_state = to_state
	
	
	## State specific things that need to run only once upon entering the next state
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
		
		STATE.LEDGE_CLIMB:
			animated_sprite.play("ledge_climb")
			velocity = Vector2.ZERO
			global_position.y = ledge_climb_ray_cast.get_collision_point().y
			can_double_jump = true
				
		STATE.LEDGE_JUMP:
			animated_sprite.play("double_jump")
			velocity.y = LEDGE_JUMP_VELOCITY
			can_dash = true
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
			can_dash = previous_state == STATE.FLOOR
			dash_jump_buffer = false


func process_state(delta: float) -> void:
	match active_state:
		STATE.FALL:
			velocity.y = move_toward(velocity.y, FALL_VELOCITY, FALL_GRAVITY * delta)
			if is_sprinting:
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
			elif is_input_toward_facing() and is_ledge() and is_space():
				switch_state(STATE.LEDGE_CLIMB)
			elif Input.is_action_just_pressed("sprint") and can_dash:
				switch_state(STATE.DASH)
			
		STATE.FLOOR:
			if is_sprinting:
				animated_sprite.play("sprint")
				handle_sprint(delta)
			else:
				if Input.get_axis("move_left", "move_right"):
					animated_sprite.play("walk")
				else:
					animated_sprite.play("idle")
				handle_movement()
			
			if not is_on_floor():
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("jump"):
				switch_state(STATE.JUMP)
			elif Input.is_action_just_pressed("sprint"):
				switch_state(STATE.DASH)
		
		
		STATE.JUMP, STATE.DOUBLE_JUMP, STATE.LEDGE_JUMP:
			velocity.y = move_toward(velocity.y, 0, JUMP_DECELERATION * delta)
			if is_sprinting:
				handle_sprint(delta)
			else:
				handle_movement()
			
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				velocity.y = 0
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("sprint") and can_dash:
				switch_state(STATE.DASH)
		
		
		STATE.FLOAT:
			velocity.y = move_toward(velocity.y, FLOAT_VELOCITY, FLOAT_GRAVITY * delta)
			handle_movement()
			
			if is_on_floor():
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_released("jump"):
				float_cooldown.start()
				switch_state(STATE.FALL)
			elif is_input_toward_facing() and is_ledge() and is_space():
				switch_state(STATE.LEDGE_CLIMB)
			elif Input.is_action_just_pressed("sprint") and can_dash:
				switch_state(STATE.DASH)
		
		
		STATE.LEDGE_CLIMB:
			is_sprinting = Input.is_action_pressed("sprint")
			if not animated_sprite.is_playing():
				animated_sprite.play("idle")
				var offset := ledge_climb_offset()
				offset.x *= facing_direction
				position += offset
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_pressed("jump"):
				var progress := inverse_lerp(0, animated_sprite.sprite_frames.get_frame_count("ledge_climb"), animated_sprite.frame)
				var offset := ledge_climb_offset()
				offset.x *= facing_direction * progress
				position += offset
				switch_state(STATE.LEDGE_JUMP)
		
		STATE.DASH:
			is_sprinting = Input.is_action_pressed("sprint")
			dash_cooldown.start()
			if is_on_floor():
				coyote_timer.start()
			if Input.is_action_just_pressed("jump"):
				dash_jump_buffer = true
			var distance := absf(position.x - saved_position.x)
			if distance >= DASH_LENGTH or signf(get_last_motion().x) != facing_direction:
				if dash_jump_buffer and coyote_timer.time_left > 0:
					switch_state(STATE.JUMP)
				elif is_on_floor():
					switch_state(STATE.FLOOR)
				else:
					switch_state(STATE.FALL)
			elif is_ledge() and is_space():
				switch_state(STATE.LEDGE_CLIMB)
		


func handle_movement(input_direction: float = 0, horizontal_velocity: float = WALK_VELOCITY, step: float = WALK_VELOCITY) -> void:
	if input_direction == 0:
		input_direction = signf(Input.get_axis("move_left", "move_right"))
	set_facing_direction(input_direction)
	velocity.x = move_toward(velocity.x, input_direction * horizontal_velocity, step)


func handle_sprint(delta: float) -> void:
	handle_movement(facing_direction, SPRINT_VELOCITY, SPRINT_ACCELERATION * delta)
	is_sprinting = Input.is_action_pressed("sprint")



func set_facing_direction(direction: float) -> void:
	if direction:
		animated_sprite.flip_h = direction < 0
		facing_direction = direction
		ledge_climb_ray_cast.position.x = direction * absf(ledge_climb_ray_cast.position.x)
		ledge_climb_ray_cast.target_position.x = direction * absf(ledge_climb_ray_cast.target_position.x)
		ledge_climb_ray_cast.force_raycast_update()


func is_input_toward_facing() -> bool:
	return signf(Input.get_axis("move_left", "move_right")) == facing_direction

func is_ledge() -> bool:
	return is_on_wall_only() and \
	ledge_climb_ray_cast.is_colliding() and \
	ledge_climb_ray_cast.get_collision_normal().is_equal_approx(Vector2.UP)


func is_space() -> bool:
	ledge_space_ray_cast.global_position = ledge_climb_ray_cast.get_collision_point()
	ledge_space_ray_cast.force_raycast_update()
	return not ledge_space_ray_cast.is_colliding()

func ledge_climb_offset() -> Vector2:
	var shape := player_collider.shape
	if shape is CapsuleShape2D:
		return Vector2(shape.radius * 2.0, -shape.height * 0.5)
	return Vector2.ZERO
