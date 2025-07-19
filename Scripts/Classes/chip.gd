class_name Chip
extends Sprite2D

var type : BetVisualManager.CHIP_COLORS:
	set(value):
		type = value
		texture = BetVisualManager.CHIP_DATA[type].texture
