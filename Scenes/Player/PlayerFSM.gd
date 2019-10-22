extends StateMachine

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
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
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			print("Idle")
		states.run:
			print("Run")
		states.jump:
			print("Jump")
		states.fall:
			print("Fall")
		states.shoot:
			print("Shoot")

func _exit_state(old_state, new_state):
	pass