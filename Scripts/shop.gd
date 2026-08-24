extends Node2D

@onready var coins_label = $CanvasLayer/CoinsLabel
@onready var seller = $CanvasLayer/seller

func _on_leave_shop_button_pressed():

	GameState.in_shop = true
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _process(_delta):

	coins_label.text = "Coins: " + str(GameState.saved_coins)

func _ready():

	seller.seller_clicked.connect(_on_seller_clicked)

	update_coin_multiplier_button()
	update_extra_hit_button()
	update_longer_power_button()

func _on_seller_clicked():

	$CanvasLayer/SellerDialogue.visible = true

	await get_tree().create_timer(3.0).timeout

	$CanvasLayer/SellerDialogue.visible = false
	$CanvasLayer/UpgradeMenu.visible = true

func _on_close_button_pressed():

	$CanvasLayer/UpgradeMenu.visible = false

func update_coin_multiplier_button():

	var level = GameState.coin_multiplier_level

	match level:

		0:
			$CanvasLayer/UpgradeMenu/CoinMultiplierButton.text = "🪙 Coin Multiplier\n1.0x\nCost: 5"

		1:
			$CanvasLayer/UpgradeMenu/CoinMultiplierButton.text = "🪙 Coin Multiplier\n1.2x\nCost: 10"

		2:
			$CanvasLayer/UpgradeMenu/CoinMultiplierButton.text = "🪙 Coin Multiplier\n1.35x\nCost: 20"

		3:
			$CanvasLayer/UpgradeMenu/CoinMultiplierButton.text = "🪙 Coin Multiplier\n1.5x\nMAX"

func _on_coin_multiplier_button_pressed():

	var level = GameState.coin_multiplier_level

	if level == 3:
		return

	var prices = [5, 10, 20]
	var price = prices[level]

	if GameState.saved_coins < price:
		return

	GameState.saved_coins -= price
	GameState.coin_multiplier_level += 1
	$PurchaseSound.play()
	update_coin_multiplier_button()

	coins_label.text = "Coins: " + str(int(GameState.saved_coins))

func _on_extra_hit_button_pressed():

	if GameState.extra_hit_purchased:
		return

	if GameState.saved_coins < 20:
		return

	GameState.saved_coins -= 20
	GameState.extra_hit = true
	GameState.extra_hit_purchased = true
	$PurchaseSound.play()
	$CanvasLayer/CoinsLabel.text = "Coins: " + str(int(GameState.saved_coins))

	update_extra_hit_button()

func update_extra_hit_button():

	if GameState.extra_hit_purchased:
		$CanvasLayer/UpgradeMenu/ExtraHitButton.text = "🛡️ Extra Hit\nOWNED"

	else:
		$CanvasLayer/UpgradeMenu/ExtraHitButton.text = "🛡️ Extra Hit\n1 use\nCost: 20"

func update_longer_power_button():

	var level = GameState.longer_power_level
	var price = 5 if level < 3 else 10

	$CanvasLayer/UpgradeMenu/LongerPowerButton.text = "🕐 Longer Power\n+" + str(level + 1) + " second\nCost: " + str(price)

func _on_longer_power_button_pressed():

	var level = GameState.longer_power_level
	var price = 5 if level < 3 else 10

	if GameState.saved_coins < price:
		return
	GameState.saved_coins -= price
	GameState.longer_power_level += 1
	$PurchaseSound.play()
	$CanvasLayer/CoinsLabel.text = "Coins: " + str(int(GameState.saved_coins))

	update_longer_power_button()
func _on_shop_music_finished():
	$ShopMusic.play()
