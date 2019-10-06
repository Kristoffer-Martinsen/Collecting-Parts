extends Area2D

var velocity = Vector2()
var speed = 16 * 2
var direction = 1

func _physics_process(delta):
	change_direction()
	velocity.x = speed 
	translate(velocity * delta * direction)
	$AnimatedSprite.play()

func change_direction():
	if $RayCastDown.is_colliding() != true || $RayCastSide.is_colliding():
		direction *= -1
		$AnimatedSprite.scale.x *= -1
		$RayCastDown.position *= -1
		$RayCastSide.cast_to *= -1