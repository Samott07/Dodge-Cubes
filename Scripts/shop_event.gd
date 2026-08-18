extends Area2D

@export var fall_speed := 200.0

func _ready():
	add_to_group("shop_event")
	body_entered.connect(_on_body_entered)

func _process(delta):
	position.y += fall_speed * delta

	if position.y > 850:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		get_parent().show_shop_question()
		queue_free()
