class_name BoardGoalColor
extends BoardGoal

@export var color: ButtonState.ButtonColor = ButtonState.ButtonColor.GRAY

func check(state: BoardState, corner: int) -> bool:
	return state.buttons[corner].color == color

func serialize() -> PackedByteArray:
	return PackedByteArray([1, color])
