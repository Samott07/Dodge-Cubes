extends Control


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_button_exit_button_pressed():
	get_tree().quit()
	
func _on_creditos_pressed():
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
