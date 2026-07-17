extends Area2D

@export var speed := 250.0

func _process(delta):

	position.y += speed * delta

	if position.y > 750:

		queue_free()


func _on_body_entered(body):

	if body.is_in_group("player"):

		get_parent().end_game()


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
