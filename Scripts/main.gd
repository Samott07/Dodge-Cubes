extends Node2D

const SAVE_FILE = "user://save.dat"

@export var enemy_scene: PackedScene
@export var mystery_scene: PackedScene
@export var shop_scene: PackedScene
@onready var alien_timer = $AlienTimer
var story_npc_instance: Node = null
var story_broken_wall_instance: Node = null
var normal_background = Color("5a8dff")
var alien_background = Color("ee5f00ff")
var story_event_used := false
var alien_event = false
var story_npc_scene = preload("res://Scenes/story_npc.tscn")
var story_broken_wall_scene = preload("res://Scenes/story_broken_wall.tscn")
var alien_scene = preload("res://Scenes/alien.tscn")
var alien_mystery_scene = preload("res://Scenes/alien_mystery.tscn")
var shop_question_open := false
var paused := false
var score := 0.0
var best_score := 0
var double_score := false
var enemy_rush = false
var coins := 0.0
var coin_fraction := 0.0
var coin_multiplier_level := 0
var extra_hit := false
var longer_power_level := 0
var story_wall_position := Vector2(800, 485)
func _ready():
	RenderingServer.set_default_clear_color(normal_background)

	load_best_score()
	if GameState.in_shop:
		score = GameState.saved_score
		coins = GameState.saved_coins
		coin_multiplier_level = GameState.coin_multiplier_level
		extra_hit = GameState.extra_hit
		longer_power_level = GameState.longer_power_level
		GameState.in_shop = false
	$CanvasLayer/BestScore.text = "Best: " + str(best_score)
	$StartSound.play()
	randomize()

	$AlienTimer.wait_time = randf_range(35.0, 55.0)
	$AlienTimer.start()
	$ShopTimer.wait_time = randf_range(50.0, 100.0)
	$ShopTimer.start()
func _process(delta):

	if double_score:
		score += delta * 2
	else:
		score += delta

	$CanvasLayer/Score.text = str(int(score))
	$CanvasLayer/CoinsLabel.text = "Coins: " + str(int(coins))
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
	if extra_hit:
		extra_hit = false
		GameState.extra_hit = false
		$CanvasLayer/EffectLabel.text = "🛡️ EXTRA HIT!"
		$CanvasLayer/EffectLabel.visible = true
		await get_tree().create_timer(1.0).timeout
		$CanvasLayer/EffectLabel.visible = false
		return
	var tree = get_tree()
	tree.paused = false
	paused = false
	double_score = false
	enemy_rush = false
	$CanvasLayer/EffectLabel.visible = false
	$Timer.stop()
	$MysteryTimer.stop()
	$AlienTimer.stop()
	$DeathSound.play()
	save_best_score()
	for enemy in tree.get_nodes_in_group("enemy"):
		enemy.queue_free()
	for block in tree.get_nodes_in_group("mystery"):
		block.queue_free()

	tree.call_group("player", "queue_free")
	$CanvasLayer/GameOver.visible = true
	await tree.create_timer(2.0).timeout

	if is_instance_valid(tree):
		tree.reload_current_scene()
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
	await get_tree().create_timer(get_power_duration()).timeout
	if is_instance_valid($Player):
		$Player.speed = old_speed
	$CanvasLayer/EffectLabel.visible = false
func double_score_effect():

	$CanvasLayer/EffectLabel.text = "⭐ DOUBLE SCORE"
	$CanvasLayer/EffectLabel.visible = true
	double_score = true
	await get_tree().create_timer(get_power_duration()).timeout
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

	$AlienTimer.wait_time = randf_range(35.0, 55.0)
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
	var effect = randi_range(1, 100)
	if effect <= 40:
		small_player_effect()
	elif effect <= 80:
		enemy_rush_effect()
	else:
		coin_reward_effect()
func small_player_effect():

	$CanvasLayer/EffectLabel.text = "🐜 SMALL!"
	$CanvasLayer/EffectLabel.visible = true

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var old_scale = player.scale
	player.scale = old_scale * 0.5
	await get_tree().create_timer(get_power_duration()).timeout
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
	await get_tree().create_timer(get_power_duration()).timeout
	enemy_rush = false

	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.speed = old_speeds[enemy]
	$CanvasLayer/EffectLabel.visible = false
func coin_reward_effect():

	coins += 25
	$CanvasLayer/EffectLabel.text = "🪙 +25 COINS!"
	$CanvasLayer/EffectLabel.visible = true
	await get_tree().create_timer(2.0).timeout
	$CanvasLayer/EffectLabel.visible = false
func _on_shop_timer_timeout():
	var shop = shop_scene.instantiate()
	shop.position = Vector2(
		randf_range(40, 1240),
		-200
	)
	add_child(shop)
	$ShopTimer.wait_time = randf_range(50.0, 100.0)
	$ShopTimer.start()
func show_shop_question():
	if shop_question_open:
		return
	shop_question_open = true
	get_tree().paused = true
	$CanvasLayer/ShopQuestion.visible = true
func _on_no_button_pressed():

	$CanvasLayer/ShopQuestion/NoButton.disabled = true
	$CanvasLayer/ShopQuestion/YesButton.disabled = true
	$CanvasLayer/ShopQuestion/CountdownLabel.visible = true
	for number in [3, 2, 1]:
		$CanvasLayer/ShopQuestion/CountdownLabel.text = str(number)
		await get_tree().create_timer(1.0, true).timeout
	$CanvasLayer/ShopQuestion/CountdownLabel.text = "GO!"
	await get_tree().create_timer(0.5, true).timeout
	$CanvasLayer/ShopQuestion.visible = false
	$CanvasLayer/ShopQuestion/CountdownLabel.visible = false
	$CanvasLayer/ShopQuestion/NoButton.disabled = false
	$CanvasLayer/ShopQuestion/YesButton.disabled = false
	shop_question_open = false
	get_tree().paused = false
func _on_yes_button_pressed():
	$CanvasLayer/ShopQuestion.visible = false
	shop_question_open = false
	GameState.in_shop = true
	GameState.saved_score = score
	GameState.saved_coins = coins
	GameState.coin_multiplier_level = coin_multiplier_level
	GameState.extra_hit = extra_hit
	GameState.longer_power_level = longer_power_level
	GameState.extra_hit_purchased = GameState.extra_hit_purchased
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Shop.tscn")
func get_coin_multiplier() -> float:
	match coin_multiplier_level:
		0:
			return 1.0
		1:
			return 1.2
		2:
			return 1.35
		3:
			return 1.5
	return 1.0
func _on_coin_timer_timeout():
	coin_fraction += get_coin_multiplier()
	var whole_coins = int(coin_fraction)
	if whole_coins > 0:
		coins += whole_coins
		coin_fraction -= whole_coins
func reset_run_data():
	GameState.knows_nyx_name = false
	GameState.saved_score = 0.0
	GameState.saved_coins = 0.0
	GameState.coin_multiplier_level = 0
	GameState.extra_hit = false
	GameState.extra_hit_purchased = false
	GameState.in_shop = false
	coins = 0.0
	coin_multiplier_level = 0
	extra_hit = false
	GameState.longer_power_level = 0
	longer_power_level = 0
	story_event_used = false
func get_power_duration() -> float:
	return 5.0 + longer_power_level
func _on_story_timer_timeout():
	if !GameState.history_mode:
		return
	if story_event_used:
		return
	story_event_used = true
	var npc = story_npc_scene.instantiate()
	add_child(npc)
	story_npc_instance = npc
	npc.position = Vector2(500, 485)
	$StoryTimer.stop()
	$CanvasLayer/StoryDialogue.visible = true
	get_tree().paused = true
func _on_no_button_2_pressed():
	$CanvasLayer/StoryDialogue.visible = false
	if is_instance_valid(story_npc_instance):
		story_npc_instance.queue_free()
		story_npc_instance = null
	get_tree().paused = false
func _on_yes_button_2_pressed() -> void:
	$CanvasLayer/StoryDialogue.visible = false
	await story_cutscene()
func story_cutscene():
	if !is_instance_valid(story_npc_instance):
		get_tree().paused = false
		return
	var tree = get_tree()
	# Pequena pausa antes do NPC começar a andar
	await tree.create_timer(0.5, true).timeout
	# NPC vai até à parede
	var npc_tween = create_tween()
	npc_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	npc_tween.tween_property(
		story_npc_instance,
		"position",
		Vector2(1055, 485),
		2.0
	)
	await npc_tween.finished
	# Pequena pausa quando chega à parede
	await tree.create_timer(0.5, true).timeout
	# Criar a parede partida
	story_broken_wall_instance = story_broken_wall_scene.instantiate()
	add_child(story_broken_wall_instance)
	story_broken_wall_instance.position = Vector2(0, 0)
	story_broken_wall_instance.visible = true
	# Encontrar o Player
	var player = tree.get_first_node_in_group("player")
	if player != null:
		# Parar completamente o movimento do Player
		player.velocity = Vector2.ZERO
		player.set_process(false)
		player.set_physics_process(false)
		# Player vai automaticamente até ao NPC
		var player_tween = create_tween()
		player_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		player_tween.tween_property(
			player,
			"position",
			Vector2(1100, 670),
			2.0
		)
		await player_tween.finished
		# Garantir que fica parado
		player.velocity = Vector2.ZERO
	# Pequena pausa antes de atravessar
	await tree.create_timer(0.5, true).timeout
	# NPC e Player atravessam a parede
	var npc_cross_tween = create_tween()
	npc_cross_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	npc_cross_tween.tween_property(
		story_npc_instance,
		"position",
		Vector2(1280, 485),
		1.0
	)
	var player_cross_tween = create_tween()
	player_cross_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	player_cross_tween.tween_property(
		player,
		"position",
		Vector2(1280, 670),
		1.0
	)
	await npc_cross_tween.finished
	# Pequena pausa antes de mudar de cena
	await tree.create_timer(0.5, true).timeout
	# Entrar no Kingdom
	GameState.in_kingdom = true
	GameState.kingdom_player_position = Vector2(21, 665)
	tree.paused = false
	tree.change_scene_to_file("res://Scenes/kingdom.tscn")
func _on_arena_music_finished():
	$ArenaMusic.play()
