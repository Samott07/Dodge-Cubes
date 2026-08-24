extends Control

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_button_exit_button_pressed():
	get_tree().quit()

func _on_creditos_pressed():
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
func _on_tutorial_pressed():

	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")
func _ready():
	update_history_mode()
func _on_history_button_pressed():
	GameState.history_mode = !GameState.history_mode
	update_history_mode()
func update_history_mode():
	if GameState.history_mode:
		$CanvasLayer/HistoryMode/HistoryLabel.text = "History mode: ON"
		$CanvasLayer/HistoryMode/HistoryButton.text = "YES  < =  NO"
	else:
		$CanvasLayer/HistoryMode/HistoryLabel.text = "History mode: OFF"
		$CanvasLayer/HistoryMode/HistoryButton.text = "YES  = >  NO"
