extends CharacterBody2D

@export var speed := 400.0

func _physics_process(_delta):

	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	velocity.y = 0

	move_and_slide()

	position.x = clamp(position.x, 20, 1220)
