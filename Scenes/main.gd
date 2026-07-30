extends Node2D

const SAVE_FILE = "user://save.dat"
var paused := false
@export var enemy_scene: PackedScene

var score := 0.0
var best_score := 0

func _ready():
	load_best_score()
	$CanvasLayer/BestScore.text = "Best: " + str(best_score)
	$StartSound.play()
func _process(delta):

	score += delta

	$CanvasLayer/Score.text = str(int(score))

	if score > best_score:
		best_score = int(score)
		$CanvasLayer/BestScore.text = "Best: " + str(best_score)
func _on_timer_timeout():

	var enemy = enemy_scene.instantiate()

	enemy.speed = randf_range(180.0, 450.0)

	add_child(enemy)

	enemy.position.x = randf_range(20, 1260)
	enemy.position.y = -20

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

	$Timer.stop()

	$DeathSound.play()

	save_best_score()

	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()

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
