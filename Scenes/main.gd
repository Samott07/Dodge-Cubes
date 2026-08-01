extends Node2D

const SAVE_FILE = "user://save.dat"

@export var enemy_scene: PackedScene
@export var mystery_scene: PackedScene

var paused := false
var score := 0.0
var best_score := 0
var double_score := false
func _ready():
	load_best_score()
	$CanvasLayer/BestScore.text = "Best: " + str(best_score)
	$StartSound.play()
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

	double_score = false
	$CanvasLayer/EffectLabel.visible = false

	$Timer.stop()
	$MysteryTimer.stop()

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

	# Como o Timer está com One Shot desligado,
	# basta alterar o próximo tempo.
	$MysteryTimer.wait_time = randf_range(20.0, 40.0)
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
