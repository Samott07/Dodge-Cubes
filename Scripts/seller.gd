extends Area2D

signal seller_clicked

func _ready():
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			seller_clicked.emit()

	elif event is InputEventScreenTouch:
		if event.pressed:
			seller_clicked.emit()
