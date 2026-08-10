extends Node2D

const SAVE_FILE = "user://save.dat"

@export var enemy_scene: PackedScene
@export var mystery_scene: PackedScene
var alien_scene = preload("res://Scenes/alien.tscn")
var alien_mystery_scene = preload("res://Scenes/alien_mystery.tscn")
var alien_event = false
var paused := false
var score := 0.0
var best_score := 0
var double_score := false
var enemy_rush = false
var normal_background = Color("5a8dff")
var alien_background = Color("FF6600")

func _ready():
	RenderingServer.set_default_clear_color(normal_background)

	load_best_score()
	$CanvasLayer/BestScore.text = "Best: " + str(best_score)
	$StartSound.play()

	randomize()

	$AlienTimer.wait_time = randf_range(30.0, 50.0)
	$AlienTimer.start()
func _process(delta):

	if double_score:
		score += delta * 2
	else:
		score += delta

	$CanvasLayer/Score.text = str(int(score))

	if score > best_score:
		best_score = int(score)
		$CanvasLayer/BestScore.text = "Best: " + str(best_score)
func _on_timer_timeout():

	var enemy = enemy_scene.instantiate()
	enemy.speed = randf_range(180.0, 450.0)

	if enemy_rush:
		enemy.speed *= 1.5

	add_child(enemy)

	enemy.position = Vector2(
		randf_range(20, 1260),
		-20
	)

	$Timer.wait_time = max(0.25, 1.0 - score * 0.02)
func load_best_score():

	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		best_score = file.get_32()
func save_best_score():

	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_32(best_score)
func toggle_pause():

	paused = !paused
	get_tree().paused = paused
	$CanvasLayer/PauseMenu.visible = paused
func end_game():
	get_tree().paused = false
	paused = false

	double_score = false
	$CanvasLayer/EffectLabel.visible = false

	$Timer.stop()
	$MysteryTimer.stop()
	$AlienTimer.stop()

	$DeathSound.play()

	save_best_score()

	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()

	for block in get_tree().get_nodes_in_group("mystery"):
		block.queue_free()

	get_tree().call_group("player", "queue_free")

	$CanvasLayer/GameOver.visible = true

	await get_tree().create_timer(2.0).timeout

	get_tree().reload_current_scene()
func _on_pause_button_pressed():
	toggle_pause()
func _unhandled_input(event):

	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
func _on_restart_button_pressed():

	get_tree().paused = false
	get_tree().reload_current_scene()
func _on_main_menu_button_pressed():

	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
func _on_mystery_timer_timeout():

	var block = mystery_scene.instantiate()

	block.position = Vector2(
		randf_range(40, 1240),
		-40
	)

	add_child(block)

	$MysteryTimer.wait_time = randf_range(20.0, 40.0)
	$MysteryTimer.start()
func activate_mystery():

	if get_tree().paused:
		return

	var effect = randi() % 2

	if effect == 0:
		slow_player()
	else:
		double_score_effect()
func slow_player():

	$CanvasLayer/EffectLabel.text = "🐢 SLOW"
	$CanvasLayer/EffectLabel.visible = true

	var old_speed = $Player.speed
	$Player.speed *= 0.4

	await get_tree().create_timer(5.0).timeout

	if is_instance_valid($Player):
		$Player.speed = old_speed

	$CanvasLayer/EffectLabel.visible = false
func double_score_effect():

	$CanvasLayer/EffectLabel.text = "⭐ DOUBLE SCORE"
	$CanvasLayer/EffectLabel.visible = true

	double_score = true

	await get_tree().create_timer(5.0).timeout

	double_score = false
	$CanvasLayer/EffectLabel.visible = false
func _on_alien_timer_timeout():

	if randi() % 2 == 0:

		alien_event = true
		RenderingServer.set_default_clear_color(alien_background)

		$CanvasLayer/AlienEventLabel.text = "Alien Event!"
		$CanvasLayer/AlienEventLabel.visible = true
		await get_tree().create_timer(2.0).timeout
		$CanvasLayer/AlienEventLabel.visible = false

		var alien = alien_scene.instantiate()
		add_child(alien)

		alien.position = Vector2(-120, 80)

	$AlienTimer.wait_time = randf_range(30.0, 50.0)
	$AlienTimer.start()
func finish_alien_event():

	RenderingServer.set_default_clear_color(normal_background)

	alien_event = false

	$CanvasLayer/AlienEventLabel.text = "The aliens... left a present?"
	$CanvasLayer/AlienEventLabel.visible = true

	await get_tree().create_timer(2.0).timeout

	$CanvasLayer/AlienEventLabel.visible = false

	var box = alien_mystery_scene.instantiate()

	add_child(box)

	box.position = Vector2(
	randf_range(40, 1240),
	-40
)
func activate_alien_mystery():
	if get_tree().paused:
		return

	var effect = randi() % 2
	if effect == 0:
		small_player_effect()
	else:
		enemy_rush_effect()
func small_player_effect():
	$CanvasLayer/EffectLabel.text = "🐜 SMALL!"
	$CanvasLayer/EffectLabel.visible = true

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var old_scale = player.scale
	player.scale = old_scale * 0.5

	await get_tree().create_timer(5.0).timeout

	if is_instance_valid(player):
		player.scale = old_scale
	$CanvasLayer/EffectLabel.visible = false
func enemy_rush_effect():

	$CanvasLayer/EffectLabel.text = "⚡ ENEMY RUSH!"
	$CanvasLayer/EffectLabel.visible = true

	enemy_rush = true

	var enemies = get_tree().get_nodes_in_group("enemy")
	var old_speeds = {}

	for enemy in enemies:

		old_speeds[enemy] = enemy.speed
		enemy.speed *= 1.5

	await get_tree().create_timer(5.0).timeout

	enemy_rush = false

	for enemy in enemies:

		if is_instance_valid(enemy):
			enemy.speed = old_speeds[enemy]

	$CanvasLayer/EffectLabel.visible = false
