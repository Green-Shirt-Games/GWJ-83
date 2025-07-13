extends Node

enum CARD_SUITS{SPADE, HEART, DIAMOND, CLUB}
enum CARD_VALUES{VA, V2, V3, V4, V5, V6, V7, V8, V9, V10, VJ, VQ, VK}
enum GAME_STATES { BETTING, DEALING, PLAYER_TURN, DEALER_TURN, RESULT, RESET} 

const SUBSCENE_PATHS : Dictionary[String, String] = {
	"card_visual" : "res://Scenes/SubScenes/card_visual.tscn" ,
}

const POINTS_LIMIT = 41

# Player's data
var money = 10000 :
	set(value):
		money = value
		money_changed.emit()
signal money_changed
