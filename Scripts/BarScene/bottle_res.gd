extends Resource
class_name BottleData

enum TYPE {
	PEEK_DEALER,
	PEEK_SHOE,
	SWAP_DEALER,
	SPILL,
	SHOE_SWAP,
	ROTATE,
	DOUBLE,
	KEY
}

@export var type : TYPE
@export var drink_name : String
@export var description : String
@export var price : int 
