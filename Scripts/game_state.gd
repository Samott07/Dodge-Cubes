extends Node

var history_mode := true
var in_shop := false
var in_kingdom := false
var kingdom_player_position := Vector2.ZERO
var saved_score := 0.0
var saved_coins := 0.0
var purchases: Array[String] = []
var knows_nyx_name := false
var coin_multiplier_level := 0
var extra_hit := false
var extra_hit_purchased := false
var longer_power_level := 0
