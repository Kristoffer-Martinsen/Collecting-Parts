extends KinematicBody2D

# ABILITY VARIABLES
export (bool) var walk = false
export (bool) var jump = false
export (bool) var push = false
export (bool) var wall_jump = false
export (bool) var attack = false

# SIGNALS
signal killed()
signal module_aquired()

# Checkpoint vector
var checkpoint = Vector2(288,26) 

# Bullet
var can_shoot = true
var shoot_direction = 1
onready var bullet_scene = preload("res://Scenes/Player/Bullet.tscn")
var is_shooting = false

# CUT SCENE VARIABLE
var cut_scene = false

# MOVEMENT VARIABLES
var velocity = Vector2()
var move_speed = 3 * Globals.UNIT_SIZE # Singelton for tilesize - 16px
var direction

# PUSH RIGIDBODY
export (int, 0, 200) var inertia = 0

# JUMP VARIABLES
var max_jump_velocity
var min_jump_velocity
var max_jump_height = 3 * Globals.UNIT_SIZE
var min_jump_height = 1 * Globals.UNIT_SIZE
var jump_duration = 0.5
var grav
var is_grounded = false
onready var raycast1 = $RayCast2D
onready var raycast2 = $RayCast2D2

# Animation
onready var anim_player = $Sprite

# WALL JUMPING
onready var left_wall_raycast = $LeftRaycast
onready var right_wall_raycast = $RightRaycast
const WALL_VELOCITY = Vector2(10*16, 8*-16)
var is_on_wall = false
var wall_direction = 1

func _ready():
	# Setting vaiables for variable jumping
	grav = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * grav * max_jump_height)
	min_jump_velocity = -sqrt(2 * grav * min_jump_height)

func _apply_gravity(delta):
	velocity.y += grav * delta

func _apply_movement():
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, PI/4, false)
	if abs(velocity.x) < 0.2:
		velocity.x = 0
	
	is_grounded = check_if_grounded()
	
	is_on_wall = check_walls()
	if is_on_wall && Input.is_action_just_pressed("ui_accept") && !is_grounded && wall_jump && !cut_scene:
		wall_jump()
		wall_direction *= -1
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("pushable") && push:
			collision.collider.apply_central_impulse(-collision.normal * inertia)
	
	# Instance bullets when pressing the shoot button
	if Input.is_action_just_pressed("ui_shoot") && can_shoot && attack:
		is_shooting = true
		shoot()
	
	if Input.is_action_just_pressed("ui_left"):
		if sign($Position2D.position.x) == 1:
			$Position2D.position.x *= -1
	elif Input.is_action_just_pressed("ui_right"):
		if sign($Position2D.position.x) == -1:
			$Position2D.position.x *= -1

func check_if_grounded():
	if raycast1.is_colliding() || raycast2.is_colliding():
		return true
	else:
		return false

func _handle_move_input():
	direction = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	velocity.x = lerp(velocity.x, move_speed * direction, get_h_weight())
	if direction != 0:
		$Sprite.scale.x = direction

func _on_Area2D_area_entered(area):
	if area.is_in_group("hazard"):
		emit_signal("killed")
		$AudioStreamPlayer.stream = load("res://Sounds/Death.wav")
		$AudioStreamPlayer.play()
		self.position = checkpoint
	if area.is_in_group("checkpoint"):
		checkpoint = Vector2(area.position.x, area.position.y)
		$AudioStreamPlayer.stream = load("res://Sounds/Checkpoint.wav")
		$AudioStreamPlayer.play()
		pass

func _on_JumpPower_body_entered(body):
	# Sound
	$AudioStreamPlayer.stream = load("res://Sounds/Powerup.wav")
	$AudioStreamPlayer.play()
	# Setting ablitiy flag as true
	jump = true
	
	# Send signal to show pick up text
	connect("module_aquired", $Textbox, "module_pickup")
	emit_signal("module_aquired", "JUMP MODULE AQUIRED")

func _on_PushPowerup_body_entered(body):
	# Sound
	$AudioStreamPlayer.stream = load("res://Sounds/Powerup.wav")
	$AudioStreamPlayer.play()
	# Setting abiliy flag and pushing power
	push = true
	inertia = 10
	
	# Send signal to show pick up text
	connect("module_aquired", $Textbox, "module_pickup")
	emit_signal("module_aquired", "PUSH MODULE AQUIRED")

func _on_WalkPowerup_body_entered(body):
	# Sound
	$AudioStreamPlayer.stream = load("res://Sounds/Powerup.wav")
	$AudioStreamPlayer.play()
	
	# setting ability flag
	walk = true
	
	# Send signal to show pick up text
	connect("module_aquired", $Textbox, "module_pickup")
	emit_signal("module_aquired", "MOVEMENT MODULE AQUIRED")

func _on_Wall_jump_powerUp_body_entered(body):
	# Sound
	$AudioStreamPlayer.stream = load("res://Sounds/Powerup.wav")
	$AudioStreamPlayer.play()
	# Setting ability flag
	wall_jump = true
	
	# Send signal to show pick up text
	connect("module_aquired", $Textbox, "module_pickup")
	emit_signal("module_aquired", "WALL JUMP MODULE AQUIRED")

func _on_AttackPowerup_body_entered(body):
	# Sound
	$AudioStreamPlayer.stream = load("res://Sounds/Powerup.wav")
	$AudioStreamPlayer.play()
	# Setting ability flag
	attack = true
	
	# Send signal to show pick up text
	connect("module_aquired", $Textbox, "module_pickup")
	emit_signal("module_aquired", "ATTACK MODULE AQUIRED")

func wall_jump():
	var wall_jump_velocity = WALL_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity
	pass

func get_h_weight():
	return 0.2 if is_grounded else 0.05

func check_walls():
	if left_wall_raycast.is_colliding():
		wall_direction = -1
		return true
	elif right_wall_raycast.is_colliding():
		wall_direction = 1
		return true
	else:
		return false

func shoot():
	var bullet = bullet_scene.instance()
	get_parent().add_child(bullet)
	bullet.position = $Position2D.global_position
	if sign($Position2D.position.x) == 1:
		bullet.set_direction(1)
	else:
		bullet.set_direction(-1)
	can_shoot = false
	var shoot_timer = $ShootTimer
	shoot_timer.start()

func _on_ShootTimer_timeout():
	can_shoot = true
	pass # Replace with function body.

func _on_Sprite_animation_finished():
	is_shooting = false


func _on_Win_body_entered(body):
		# Send signal to show pick up text
	connect("module_aquired", $Textbox, "module_pickup")
	emit_signal("module_aquired", "YOU ESCAPED CONGRATULATIONS")
	pass # Replace with function body.
