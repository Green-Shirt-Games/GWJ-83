class_name BottlesOnTableManager
extends Node2D

@export var bottles_locations : Array[Marker2D]
var bottles_at_locations : Array[BottleOnTable]
@export var stages_where_player_can_drink : Array[Global.GAME_STATES]

func _ready() -> void:
	for i in bottles_locations.size():
		bottles_at_locations.append(null)

func check_for_room_for_bottle(amount : int) -> bool:
	return bottles_locations.size() >= count_bottles() + amount

func add_bottle(bottle_data : BottleData) -> void:
	if !check_for_room_for_bottle(1):
		push_error("Trying to fit bottle that doesn't fit on table")
		return
	var new_bottle = BottleOnTable.new(bottle_data)
	add_child(new_bottle)
	var new_bottle_place_id = find_free_space_for_bottle()
	if new_bottle_place_id == -1:
		push_error("Can't fit bottle, no space")
		return
	bottles_at_locations[new_bottle_place_id] = new_bottle
	new_bottle.bottle_pressed.connect(bottle_pressed)
	new_bottle.position = bottles_locations[new_bottle_place_id].position - (new_bottle.get_rect().size / 2)
	new_bottle.z_index = new_bottle_place_id

func find_free_space_for_bottle() -> int:
	for i in bottles_at_locations.size():
		if bottles_at_locations[i] == null:
			return i
	return -1

func count_bottles() -> int:
	var amount : int = 0
	for bottle in bottles_at_locations:
		if bottle != null:
			amount += 1
	return amount

func bottle_pressed(bottle : BottleOnTable) -> void:
	if bottle.bottle_data:
		var bottle_had_effect = await Global.table.bottle_pressed(bottle.bottle_data.type)
		if bottle_had_effect:
			remove_bottle(bottle)
		else:
			print(bottle, " had no effect, so not used")
	else:
		print("Pressed bottle don't have data")
	#remove_bottle(bottle)

func remove_bottle(bottle_to_remove : BottleOnTable) -> void:
	bottles_at_locations[bottles_at_locations.find(bottle_to_remove)] = null
	bottle_to_remove.queue_free()

func _on_button_pressed() -> void: # Debug button
	var empty_bottle_data = BottleData.new()
	add_bottle(empty_bottle_data)

func disable_bottles_if_needed(table_stage : Global.GAME_STATES) -> void:
	var enable_bottles : bool = stages_where_player_can_drink.has(table_stage)
	for bottle in bottles_at_locations:
		if bottle and bottle is BottleOnTable:
			bottle.disabled = !enable_bottles
