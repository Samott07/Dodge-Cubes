extends Node2D

@onready var guard = $GuardCube
@onready var guard_talk_button = $GuardCube/TalkButton
@onready var guard_name_label = $GuardCube/NameLabel
@onready var guard_dialogue = $CanvasLayer/GuardDialogue
@onready var guard_question_label = $CanvasLayer/GuardDialogue/QuestionLabel
@onready var guard_answer_label = $CanvasLayer/GuardDialogue/AnswerLabel

var guard_dialogue_open := false
const GUARD_TALK_DISTANCE := 185.0
@onready var player = $Player
@onready var npc = $StoryNPC
@onready var talk_button = $StoryNPC/TalkButton
@onready var dialogue = $CanvasLayer/KingdomDialogue
@onready var question_label = $CanvasLayer/KingdomDialogue/QuestionLabel
@onready var answer_label = $CanvasLayer/KingdomDialogue/AnswerLabel
const NPC_TALK_DISTANCE := 300.0
var dialogue_open := false
func _ready():
	player.position = Vector2(21, 665)
	npc.position = Vector2(-60, 485)
	if GameState.knows_nyx_name:
		$StoryNPC/NameLabel.text = "Name: Nyx"
	else:
		$StoryNPC/NameLabel.text = "Name: ???"
	dialogue.visible = false
	talk_button.pressed.connect(_on_talk_button_pressed)
	guard_talk_button.visible = false
	guard_name_label.visible = false
	guard_dialogue.visible = false
	guard_talk_button.pressed.connect(_on_guard_talk_button_pressed)
func _on_talk_button_pressed():
	dialogue_open = true
	dialogue.visible = true
	question_label.visible = true
	question_label.text = "What do you want to ask?"
	answer_label.visible = false
	$CanvasLayer/KingdomDialogue/Question1Button.visible = true
	$CanvasLayer/KingdomDialogue/Question2Button.visible = true
	$CanvasLayer/KingdomDialogue/Question3Button.visible = true
	$CanvasLayer/KingdomDialogue/Question4Button.visible = true
	$CanvasLayer/KingdomDialogue/CloseButton.visible = true
func _on_question_1_button_pressed():
	$CanvasLayer/KingdomDialogue/QuestionLabel.visible = false
	$CanvasLayer/KingdomDialogue/AnswerLabel.text = "Sure... I can take you back to the arena."
	$CanvasLayer/KingdomDialogue/AnswerLabel.visible = true
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
func _on_question_2_button_pressed():
	$CanvasLayer/KingdomDialogue/Question1Button.visible = true
	$CanvasLayer/KingdomDialogue/Question2Button.visible = false
	$CanvasLayer/KingdomDialogue/Question3Button.visible = true
	$CanvasLayer/KingdomDialogue/Question4Button.visible = true
	$CanvasLayer/KingdomDialogue/QuestionLabel.visible = false
	$CanvasLayer/KingdomDialogue/AnswerLabel.text = "Who?"
	$CanvasLayer/KingdomDialogue/AnswerLabel.visible = true
func _on_question_3_button_pressed():
	$CanvasLayer/KingdomDialogue/Question1Button.visible = true
	$CanvasLayer/KingdomDialogue/Question2Button.visible = true
	$CanvasLayer/KingdomDialogue/Question3Button.visible = false
	$CanvasLayer/KingdomDialogue/Question4Button.visible = true
	$CanvasLayer/KingdomDialogue/QuestionLabel.visible = false
	$CanvasLayer/KingdomDialogue/AnswerLabel.text = "Well... this world... has some secrets... I can't tell you now but... you can't trust anyone..."
	$CanvasLayer/KingdomDialogue/AnswerLabel.visible = true
func _on_question_4_button_pressed():
	$CanvasLayer/KingdomDialogue/Question1Button.visible = true
	$CanvasLayer/KingdomDialogue/Question2Button.visible = true
	$CanvasLayer/KingdomDialogue/Question3Button.visible = true
	$CanvasLayer/KingdomDialogue/Question4Button.visible = false
	$CanvasLayer/KingdomDialogue/QuestionLabel.visible = false
	$CanvasLayer/KingdomDialogue/AnswerLabel.text = "I just like it... Do you think I look bad in it?"
	$CanvasLayer/KingdomDialogue/AnswerLabel.visible = true
func show_answer(text: String):
	question_label.visible = false
	answer_label.text = text
	answer_label.visible = true
func _on_close_button_pressed():
	close_dialogue()
func _process(_delta):
	if player == null or npc == null:
		return
	var distance = player.global_position.distance_to(npc.global_position)
	if distance <= NPC_TALK_DISTANCE:
		talk_button.visible = true
		$StoryNPC/NameLabel.visible = true
	else:
		talk_button.visible = false
		$StoryNPC/NameLabel.visible = false
		if dialogue_open:
			close_dialogue()
	if guard != null and player != null:
		var guard_distance = player.global_position.distance_to(guard.global_position)
		if guard_distance <= GUARD_TALK_DISTANCE:
			guard_talk_button.visible = true
			guard_name_label.visible = true
		else:
			guard_talk_button.visible = false
			guard_name_label.visible = false
			if guard_dialogue_open:
				close_guard_dialogue()
func close_dialogue():
	dialogue_open = false
	dialogue.visible = false
	question_label.visible = true
	answer_label.visible = false
	$CanvasLayer/KingdomDialogue/Question1Button.visible = true
	$CanvasLayer/KingdomDialogue/Question2Button.visible = true
	$CanvasLayer/KingdomDialogue/Question3Button.visible = true
	$CanvasLayer/KingdomDialogue/Question4Button.visible = true
func _on_guard_talk_button_pressed():
	guard_dialogue_open = true
	guard_dialogue.visible = true
	guard_question_label.visible = true
	guard_question_label.text = "What do you want to ask?"
	guard_answer_label.visible = false
	$CanvasLayer/GuardDialogue/Question1Button2.visible = true
	$CanvasLayer/GuardDialogue/Question2Button2.visible = true
	$CanvasLayer/GuardDialogue/CloseButton2.visible = true
func _on_question_1_button_2_pressed():
	guard_question_label.visible = false
	$CanvasLayer/GuardDialogue/Question1Button2.visible = false
	$CanvasLayer/GuardDialogue/Question2Button2.visible = true
	guard_answer_label.text = "No. The King and his children are passing through here. Nobody can pass."
	guard_answer_label.visible = true
func _on_question_2_button_2_pressed():
	guard_question_label.visible = false
	$CanvasLayer/GuardDialogue/Question1Button2.visible = true
	$CanvasLayer/GuardDialogue/Question2Button2.visible = false
	guard_answer_label.text = "I don't know too much about him... but I think his name is Nyx."
	guard_answer_label.visible = true
	GameState.knows_nyx_name = true
	$StoryNPC/NameLabel.text = "Name: Nyx"
func close_guard_dialogue():
	guard_dialogue_open = false
	guard_dialogue.visible = false
	guard_question_label.visible = true
	guard_answer_label.visible = false
	$CanvasLayer/GuardDialogue/Question1Button2.visible = true
	$CanvasLayer/GuardDialogue/Question2Button2.visible = true
func _on_close_button_2_pressed():
	close_guard_dialogue()
func _on_kingdom_music_finished():
	$KingdomMusic.play()
