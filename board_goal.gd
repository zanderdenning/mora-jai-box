class_name BoardGoal
extends Resource

func check(_state: BoardState, _corner: int) -> bool:
	return false

func serialize() -> PackedByteArray:
	return PackedByteArray()
