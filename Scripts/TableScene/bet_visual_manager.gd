class_name BetVisualManager
extends Node2D

@export var piles : Array[PileOfChips]
@export var soft_limit_of_chips_in_pile : int = 20

enum CHIP_COLORS{YELLOW, BLACK, GREEN, BLUE, RED, WHITE}
const CHIP_DATA : Dictionary[CHIP_COLORS,Dictionary] = {
	CHIP_COLORS.YELLOW : {
		"value" : 1000,
		"texture" : preload( "res://Assets/Chips/Black_Jack_Chips_Yellow.png"),
		"alt_texture" : preload( "res://Assets/Chips/Black_Jack_Chips_Yellow_Rotated.png"),
	},
	CHIP_COLORS.BLACK : {
		"value" : 100 ,
		"texture" : preload( "res://Assets/Chips/Black_Jack_Chips_Black.png") ,
		"alt_texture" : preload( "res://Assets/Chips/Black_Jack_Chips_Black_Rotated.png")
	} ,
	CHIP_COLORS.GREEN : {
		"value" : 25,
		"texture" : preload("res://Assets/Chips/Black_Jack_Chips_Green.png" ),
		"alt_texture" : preload( "res://Assets/Chips/Black_Jack_Chips_Green_Rotated.png"),
	} ,
	CHIP_COLORS.BLUE : {
		"value" : 10 ,
		"texture" : preload("res://Assets/Chips/Black_Jack_Chips_Blue.png" ) ,
		"alt_texture" : preload("res://Assets/Chips/Black_Jack_Chips_Blue_Rotated.png" )
	} ,
	CHIP_COLORS.RED : {
		"value" : 5,
		"texture" : preload("res://Assets/Chips/Black_Jack_Chips_Red.png" ),
		"alt_texture" : preload("res://Assets/Chips/Black_Jack_Chips_Red_Rotated.png" ),
	} ,
	CHIP_COLORS.WHITE : {
		"value" : 1,
		"texture" : preload("res://Assets/Chips/Black_Jack_Chips_White.png" ),
		"alt_texture" : preload("res://Assets/Chips/Black_Jack_Chips_White_Rotated.png" ),
	}}

var default_position : Vector2

func _ready() -> void:
	default_position = position

func reset_position() -> void:
	position = default_position


func update_bet(new_bet : int) -> void:
	split_full_list_of_chips_between_piles(
		calculate_amount_of_chips(new_bet)
	)

func calculate_amount_of_chips(bet : int) -> Dictionary:
	var chips_amounts : Dictionary[CHIP_COLORS, int] = {}
	var left_to_convert = bet
	for i in CHIP_COLORS.size():
		chips_amounts[i as int] = floori(left_to_convert / CHIP_DATA[i as int].value)
		left_to_convert = left_to_convert % CHIP_DATA[i as int].value
	return chips_amounts

func split_full_list_of_chips_between_piles(full_list_of_chips : Dictionary[CHIP_COLORS, int]) -> void:
	var total_chips := 0
	var chip_types := []
	for type in full_list_of_chips.keys():
		total_chips += full_list_of_chips[type]
		if full_list_of_chips[type] > 0:
			chip_types.append(type)
	if total_chips <= soft_limit_of_chips_in_pile:
		update_chips_in_pile(piles[0], full_list_of_chips)
		update_chips_in_pile(piles[1], {})
		update_chips_in_pile(piles[2], {})
		return
	
	var dictionary_to_be_added : Dictionary[CHIP_COLORS, int] = {}
	var dictionaries_for_piles : Array[Dictionary]
	for i in piles.size():
		dictionaries_for_piles.append(dictionary_to_be_added.duplicate())
	
	var current_pile_index := 0
	
	for chip_type in chip_types:
		var count = full_list_of_chips[chip_type]
		var remaining = count
		
		while remaining > 0:
			var current_pile_total = 0
			for i in dictionaries_for_piles[current_pile_index]:
				current_pile_total += dictionaries_for_piles[current_pile_index][i]
			
			var can_add = min(remaining, soft_limit_of_chips_in_pile - current_pile_total)
			
			if can_add > 0:
				dictionaries_for_piles[current_pile_index][chip_type] = dictionaries_for_piles[current_pile_index].get(chip_type, 0) + can_add
				remaining -= can_add
			
			if current_pile_total + can_add >= soft_limit_of_chips_in_pile or can_add == 0:
				current_pile_index += 1
				if current_pile_index >= piles.size() - 1:
					dictionaries_for_piles[2][chip_type] = dictionaries_for_piles[2].get(chip_type, 0) + remaining
					remaining = 0
	
	for i in dictionaries_for_piles.size():
		update_chips_in_pile(piles[i], dictionaries_for_piles[i])

func reset_chips_in_pile(pile : PileOfChips, list_of_chips : Dictionary[CHIP_COLORS, int]) -> void:
	pile.clear()
	if !list_of_chips.is_empty():
		SfxAutoload.place_chips()
		for chip_type in list_of_chips.keys():
			for i in list_of_chips[chip_type]:
				spawn_chip(chip_type, pile)



func update_chips_in_pile(pile : PileOfChips, list_of_chips : Dictionary[CHIP_COLORS, int]) -> void:
	reset_chips_in_pile(pile, list_of_chips)
	
	# Doesn't properly work, use if ever fixed
	#var list_of_chips_to_add : Dictionary[CHIP_COLORS, int] = {}
	#var list_of_chips_to_remove : Dictionary[CHIP_COLORS, int] = {}
	#
	#for chip_type in pile.chips_amount_in_pile:
		#var current_amount = pile.chips_amount_in_pile[chip_type]
		#var target_amount = list_of_chips.get(chip_type, 0)
		#
		#if current_amount > target_amount:
			#list_of_chips_to_remove[chip_type] = current_amount - target_amount
		#elif current_amount < target_amount:
			#list_of_chips_to_add[chip_type] = target_amount - current_amount
	#
	#for chip_type in list_of_chips:
		#if not pile.chips_amount_in_pile.has(chip_type):
			#list_of_chips_to_add[chip_type] = list_of_chips[chip_type]
	#
	#for chip_type in list_of_chips_to_remove:
		#for i in list_of_chips_to_remove[chip_type]:
			#pile.remove_chip_of_type(chip_type)
	#
	#for chip_type in list_of_chips_to_add.keys():
		#for i in list_of_chips_to_add[chip_type]:
			#spawn_chip(chip_type, pile)
	#pile.update_chips_amount()
	
	
	pile.update_chips_position()

func spawn_chip(type : CHIP_COLORS, in_pile : PileOfChips) -> void:
	var new_chip = Chip.new()
	new_chip.type = type as CHIP_COLORS
	in_pile.add_child(new_chip)

func clear_all_piles() -> void:
	for pile in piles:
		pile.clear()
