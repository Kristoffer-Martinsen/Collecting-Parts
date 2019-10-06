extends Area2D

onready var bullet_scene = preload("res://Scenes/Actors/BossShot.tscn")
onready var shot_timer = $Shoot_timer

func _ready():
	shot_timer.wait_time = floor(2 + rand_range(-1, 3))
	shot_timer.start()

func _physics_process(delta):
	check_if_dead()
	pass

func check_if_dead(): 
	if $CoolingTanks.get_child_count() == 0:
		queue_free()

func _on_Shoot_timer_timeout():
	shoot()
	shot_timer.start()
	pass # Replace with function body.

func shoot():
	var bullet = bullet_scene.instance()
	var shot_height = $Position2D.global_position.y + rand_range(-32, 32)
	get_parent().add_child(bullet)
	bullet.position = Vector2($Position2D.global_position.x, shot_height)
