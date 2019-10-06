extends Node2D



func module_pickup(string):
	var text = string
	var label = $Label
	label.text = text
	self.show()
	var timer = $Timer
	timer.start()

func _on_Timer_timeout():
	self.hide()
	pass # Replace with function body.
