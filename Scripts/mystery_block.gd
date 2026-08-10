extends Area2D

@export var speed := 250.0

func _process(delta):

	position.y += speed * delta
	if position.y > 760:
		queue_free()

func _on_body_entered(body):
	
	if body.is_in_group("player"):
		get_parent().activate_mystery()

		queue_free()
