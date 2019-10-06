extends Area2D

const SPEED = 5*16
var velocity = Vector2()
var direction = 1

func _physics_process(delta):
	velocity.x = SPEED * delta * direction
	translate(velocity)
	$AnimatedSprite.play()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func set_direction(dir):
	direction = dir
	if dir == -1:
		$AnimatedSprite.flip_h = true

func _on_Bullet_area_entered(area):
	area.queue_free()
	self.queue_free()
	pass # Replace with function body.
