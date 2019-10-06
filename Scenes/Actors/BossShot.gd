extends Area2D

const SPEED = 5*16
var velocity = Vector2()
var direction = 1

func _physics_process(delta):
	velocity.x = SPEED * delta * direction
	translate(velocity)
