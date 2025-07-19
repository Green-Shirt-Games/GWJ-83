class_name PileOfChips
extends Node2D

var total_chips_value : int = 0
var chips_amount_in_pile : Dictionary = {}
var chips_y_offset = -11

func _ready() -> void:
	for color in BetVisualManager.CHIP_COLORS.values():
		chips_amount_in_pile[color] = 0


#func chip_was_added(chip : Node) -> void:
	#if chip is Chip:
		#total_chips_value += BetVisualManager.CHIP_DATA[chip.type].value
		#chips_amount_in_pile[chip.type] += 1
#
#
#func chip_was_removed(chip : Node) -> void:
	#if chip is Chip:
		#total_chips_value -= BetVisualManager.CHIP_DATA[chip.type].value
		#chips_amount_in_pile[chip.type] -= 1
		#if chips_amount_in_pile[chip.type] < 0:
			#chips_amount_in_pile[chip.type] = 0

func update_chips_amount() -> void:
	chips_amount_in_pile.clear()
	SfxAutoload.place_chips()
	for i in get_child_count():
		if get_child(i) is Chip and not get_child(i).is_queued_for_deletion():
			chips_amount_in_pile[(get_child(i) as Chip).type] = chips_amount_in_pile.get((get_child(i) as Chip).type, 0) + 1

func update_chips_position() -> void:
	var total_offset := 0
	for child_id in get_child_count():
		if not get_child(child_id).is_queued_for_deletion():
			get_child(child_id).position = Vector2.ZERO + Vector2(0, total_offset)
			total_offset += chips_y_offset

func remove_chip_of_type(type : BetVisualManager.CHIP_COLORS) -> void:
	for child in get_children():
		if child is Chip:
			if child.type == type:
				child.queue_free()
				return
		else:
			push_error("Non-chip child of pile_of_chips")
	push_error(self, " Didn't find chip to remove: " , type)

func clear() -> void:
	for child in get_children():
		child.queue_free()
