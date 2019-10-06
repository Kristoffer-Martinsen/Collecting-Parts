extends Area2D

var velocity = Vector2()
var speed = 16 * 2
var direction = 1

func _physics_process(delta):
	change_direction()
	velocity.y = speed 
	translate(velocity * delta * direction)
	$AnimatedSprite.play()

func change_direction():
	if $RayCastDown.is_colliding() || $RayCastUp.is_colliding():
		direction *= -1
		return true
	else:
		return false