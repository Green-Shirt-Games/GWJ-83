extends Resource
class_name BottleData

enum TYPE {
	PEEK_DEALER,
	PEEK_SHOE,
	SWAP,
	SPILL,
	SHOE_SWAP,
	ROTATE,
	SNEAK_BET
}

@export var type : TYPE
@export var drink_name : String
@export var description : String
@export var price : int 
