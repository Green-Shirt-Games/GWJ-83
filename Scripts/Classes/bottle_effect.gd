## Base class for bottle effects to be triggered at table

class_name BottleEffect
extends Resource

func instant_effect() -> void:
	pass
	# instant effects: triggered once, effect naturaly removed by event
	#Shoe Ray - Reveals the top card of the shoe
	#Devil Ray - Reveals the devils hidden card
	#Swap card - Swap one card for a dealers card
	#Deck Swap - Discard a card and hit a new card
	#Rotate drink - cards on the table are shuffled
	#Bluff - Allows the player to change their bet after drawing cards
		# Go back to BETTING stage and as special case go to PLAEYERS_TURN from that, skipping DEALING
	#Double Down Drink - Double bet

func temp_effects() -> void:
	pass
	# triggered once, effect stays somewhere else 'till some signal (end of turn for most of those)
	#Counter - See the count of the shoe
	#Freeze Card

func permanent_effect() -> void:
	pass
	# triggered once, effect stays somewhere permanently
	#Spill - marks a card for later
