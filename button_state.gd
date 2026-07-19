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

@export var color: ButtonColor = ButtonColor.GRAY

func serialize() -> PackedByteArray:
	return PackedByteArray([color])
