class_name PileOfChips
extends Node2D

var total_chips_value : int = 0
var chips_amount_in_pile : Dictionary = {}
var chips_y_offset = -10

func _ready() -> void:
	child_entered_tree.connect(chip_was_added)
	child_exiting_tree.connect(chip_was_removed)
	for color in BetVisualManager.CHIP_COLORS.values():
		chips_amount_in_pile[color] = 0


func chip_was_added(chip : Node) -> void:
	if chip is Chip:
		total_chips_value += BetVisualManager.CHIP_DATA[chip.type].value
		chips_amount_in_pile[chip.type] += 1


func chip_was_removed(chip : Node) -> void:
	if chip is Chip:
		total_chips_value -= BetVisualManager.CHIP_DATA[chip.type].value
		chips_amount_in_pile[chip.type] -= 1
		if chips_amount_in_pile[chip.type] < 0:
			push_error("Negative number of chips in pile!")
			chips_amount_in_pile[chip.type] = 0

func update_chips_position() -> void:
	var total_offset = 0
	for child in get_children():
		child.position = Vector2.ZERO
		child.position.y += total_offset
		total_offset += chips_y_offset
	print(total_offset)

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
