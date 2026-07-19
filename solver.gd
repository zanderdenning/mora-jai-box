class_name Solver
extends RefCounted

var visited_states: Dictionary[PackedByteArray, bool] = {}
var to_process: Array[Array] = []
var solution: PackedInt32Array

func solve(start: BoardState, max_moves: int = 1000) -> bool:
	if start.check():
		solution = PackedInt32Array()
		return true
	var start_serialized: PackedByteArray = start.serialize()
	visited_states[start_serialized] = true
	to_process.push_back([start, PackedInt32Array()])
	while not to_process.is_empty():
		var entry: Array = to_process.pop_front()
		var state: BoardState = entry[0]
		var path: PackedInt32Array = entry[1]
		if path.size() >= max_moves:
			return false
		for i in state.width * state.height:
			var copy: BoardState = state.create_copy()
			copy.activate_button(i)
			var serialized: PackedByteArray = copy.serialize()
			if not visited_states.has(serialized):
				var new_path: PackedInt32Array = path + PackedInt32Array([i])
				if copy.check():
					solution = new_path
					return true
				visited_states[serialized] = true
				to_process.push_back([copy, new_path])
	return false
