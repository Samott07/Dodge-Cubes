extends Area2D

const TALK_DISTANCE := 185.0

@onready var talk_button = $TalkButton
@onready var name_label = $NameLabel
var player: Node2D
var dialogue_open := false

func _ready():
	talk_button.visible = false
	name_label.visible = false
	player = get_tree().get_first_node_in_group("player")
func _process(_delta):
	if player == null:
		return
	var distance = global_position.distance_to(player.global_position)
	if distance <= TALK_DISTANCE:
		talk_button.visible = true
		name_label.visible = true
	else:
		talk_button.visible = false
		name_label.visible = false
		if dialogue_open:
			close_dialogue()
func _on_talk_button_pressed():
	dialogue_open = true
	# Vamos ligar isto à UI do Kingdom depois.
	print("GUARD TALK")
func close_dialogue():
	dialogue_open = false
