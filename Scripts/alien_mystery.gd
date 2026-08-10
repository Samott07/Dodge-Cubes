extends Area2D

@export var fall_speed := 200.0

func _ready():
	add_to_group("alien_mystery")

func _process(delta):
	position.y += fall_speed * delta

	if position.y > 850:
		queue_free()

func _on_body_entered(body):

	if body.is_in_group("player"):

		get_parent().activate_alien_mystery()

		queue_free()
