extends StateMachine

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("dead")
	add_state("shoot")
	call_deferred("set_state", states.idle)

func _input(event):
	if [states.idle, states.run, states.shoot].has(state):
		# Jumping
		if event.is_action_pressed("ui_accept") && parent.is_grounded && parent.jump && !parent.cut_scene:
			parent.velocity.y = parent.max_jump_velocity
	
	if state == states.jump:
		# Variable jump
		if event.is_action_released("ui_accept") && parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity

func _state_logic(delta):
	parent._handle_move_input()
	parent._apply_gravity(delta)
	parent._apply_movement()

func _get_transition(delta):
	match state:
		states.idle:
			if parent.health <= 0:
				return states.dead
			elif !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
			elif parent.is_shooting:
				return states.shoot
		states.run:
			if parent.health <= 0:
				return states.dead
			elif !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
			elif parent.is_shooting:
				return states.shoot
		states.jump:
			if parent.health <= 0:
				return states.dead
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
			elif parent.is_shooting:
				return states.shoot
		states.fall:
			if parent.health <= 0:
				return states.dead
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
			elif parent.is_shooting:
				return states.shoot
		states.shoot:
			if parent.health <= 0:
				return states.dead
			elif !parent.anim_player.is_playing():
				return states.idle
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			print("Idle")
			parent.anim_player.play("idle")
		states.run:
			print("Run")
			parent.anim_player.play("walk")
		states.jump:
			print("Jump")
			parent._play_sound("res://Sounds/Jump.wav")
			parent.anim_player.play("jump")
		states.fall:
			print("Fall")
			# parent.animation_player.play("idle")
		states.shoot:
			print("Shoot")
			parent._play_sound("res://Sounds/Shot.wav")
			parent.anim_player.play("shoot")

func _exit_state(old_state, new_state):
	pass