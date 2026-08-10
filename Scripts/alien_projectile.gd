extends Area2D

@export var speed := 300.0

var target_position := Vector2.ZERO
var direction := Vector2.ZERO

func setup(target: Vector2):
	target_position = target
	direction = global_position.direction_to(target_position)

func _process(delta):

	position += direction * speed * delta

	if position.x < -50 or position.x > 1330 or position.y < -50 or position.y > 800:
		queue_free()
func _on_body_entered(body):

	if body.is_in_group("player"):

		get_parent().end_game()

		queue_free()
