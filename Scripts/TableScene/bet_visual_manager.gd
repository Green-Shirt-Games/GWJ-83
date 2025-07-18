class_name BetVisualManager
extends Node2D

@export var pile : Node2D

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

func _ready() -> void:
	var chips_to_add : Dictionary = calculate_amount_of_chips(9999)
	for type in chips_to_add.keys():
		for i in chips_to_add[type]:
			spawn_chip(type)


func calculate_amount_of_chips(bet : int) -> Dictionary:
	var chips_amounts : Dictionary[CHIP_COLORS, int] = {}
	var left_to_convert = bet
	for i in CHIP_COLORS.size():
		chips_amounts[i as int] = floori(left_to_convert / CHIP_DATA[i as int].value)
		left_to_convert = left_to_convert % CHIP_DATA[i as int].value
	return chips_amounts

func spawn_chip(type : CHIP_COLORS) -> void:
	var new_chip = Sprite2D.new()
	print(type, type as int, type as CHIP_COLORS)
	pile.add_child(new_chip)
	new_chip.texture = CHIP_DATA[type].texture
	new_chip.position.y -= 10 * pile.get_child_count()
