class_name ButtonState
extends Resource

enum ButtonColor {
	GRAY,
	WHITE,
	YELLOW,
	VIOLET,
	GREEN,
	BLACK,
	RED,
	PINK,
	ORANGE,
	BLUE,
}

enum Sticker {
	NONE = 0,
	ALT = 1,
}

@export var color: ButtonColor = ButtonColor.GRAY
@export var alt_color: ButtonColor = ButtonColor.GRAY
@export var stickers: int = Sticker.NONE

func serialize() -> PackedByteArray:
	var out: PackedByteArray = PackedByteArray([color, stickers & 0xFF])
	if stickers & Sticker.ALT:
		out.append(alt_color)
	return out
