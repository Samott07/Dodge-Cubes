extends Node2D

@export var speed := 250.0
var projectile_scene = preload("res://Scenes/alien_projectile.tscn")
var direction := 1
var bounces := 0
var shoot_timer := 0.0
func _process(delta):

	position.x += speed * direction * delta
	shoot_timer -= delta

	if shoot_timer <= 0:

		shoot()
		shoot_timer = 1.0

	if position.x >= 1180:

		direction = -1
		bounces += 1

	if position.x <= 40 and direction == -1:

		direction = 1
		bounces += 1

	if bounces >= 4:

		get_parent().finish_alien_event()
		queue_free()
func shoot():

	var projectile = projectile_scene.instantiate()

	get_parent().add_child(projectile)

	projectile.global_position = global_position

	var player = get_tree().get_first_node_in_group("player")

	if player:
		projectile.setup(player.global_position)
	else:
		projectile.queue_free()
