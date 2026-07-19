class_name BoardState
extends Resource

@export var width: int = 3
@export var height: int = 3
@export var buttons: Array[ButtonState]
@export var goals: Array[BoardGoal]

const SERIALIZATION_VERSION = 1

func serialize() -> PackedByteArray:
	var state: PackedByteArray = PackedByteArray([SERIALIZATION_VERSION, width, height])
	for i in width * height:
		state.append_array(buttons[i].serialize())
	for i in 4:
		state.append_array(goals[i].serialize())
	return state

static func deserialize(serialized: PackedByteArray) -> BoardState:
	var version: int = serialized[0]
	if version > 1:
		return null
	var state: BoardState = BoardState.new()
	state.width = serialized[1]
	state.height = serialized[2]
	var pos: int = 3
	var button_count: int = state.width * state.height
	for i in button_count:
		var button: ButtonState = ButtonState.new()
		button.color = serialized[pos] as ButtonState.ButtonColor
		pos += 1
		if version > 0:
			button.stickers = serialized[pos]
			pos += 1
			if button.stickers & ButtonState.Sticker.ALT:
				button.alt_color = serialized[pos] as ButtonState.ButtonColor
				pos += 1
		state.buttons.append(button)
	for i in 4:
		var goal: BoardGoalColor = BoardGoalColor.new()
		goal.color = serialized[pos + 1] as ButtonState.ButtonColor
		pos += 2
		state.goals.append(goal)
	return state

func create_copy() -> BoardState:
	var copy: BoardState = BoardState.new()
	copy.width = width
	copy.height = height
	copy.goals = goals
	copy.buttons = buttons.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	return copy

func check() -> bool:
	return goals[0].check(self, 0) \
		and goals[1].check(self, width - 1) \
		and goals[2].check(self, width * height - width) \
		and goals[3].check(self, width * height - 1)

func activate_button(index: int) -> void:
	var button_state: ButtonState = buttons[index]
	var color: ButtonState.ButtonColor = button_state.color
	if color == ButtonState.ButtonColor.BLUE:
		var center_button: ButtonState = buttons[width * height / 2]
		color = center_button.color
	match color:
		ButtonState.ButtonColor.GRAY:
			pass
		ButtonState.ButtonColor.WHITE:
			_activate_white(index, button_state)
		ButtonState.ButtonColor.YELLOW:
			_activate_yellow(index, button_state)
		ButtonState.ButtonColor.VIOLET:
			_activate_violet(index, button_state)
		ButtonState.ButtonColor.GREEN:
			_activate_green(index, button_state)
		ButtonState.ButtonColor.BLACK:
			_activate_black(index, button_state)
		ButtonState.ButtonColor.RED:
			_activate_red(index, button_state)
		ButtonState.ButtonColor.PINK:
			_activate_pink(index, button_state)
		ButtonState.ButtonColor.ORANGE:
			_activate_orange(index, button_state)
		ButtonState.ButtonColor.BLUE:
			pass
		_:
			pass
	if button_state.stickers & ButtonState.Sticker.ALT:
		var button_color: ButtonState.ButtonColor = button_state.color
		button_state.color = button_state.alt_color
		button_state.alt_color = button_color

func _activate_white(index: int, button_state: ButtonState) -> void:
	for neighbor in _get_adjacent_positions(index):
		var state: ButtonState = buttons[neighbor]
		if state.color == button_state.color:
			state.color = ButtonState.ButtonColor.GRAY
		elif state.color == ButtonState.ButtonColor.GRAY:
			state.color = button_state.color
	buttons[index].color = ButtonState.ButtonColor.GRAY

func _activate_yellow(index: int, button_state: ButtonState) -> void:
	if index < width:
		return
	var new_index: int = index - 3
	buttons[index] = buttons[new_index]
	buttons[new_index] = button_state

func _activate_violet(index: int, button_state: ButtonState) -> void:
	if index > (width * height) - width - 1:
		return
	var new_index: int = index + 3
	buttons[index] = buttons[new_index]
	buttons[new_index] = button_state

func _activate_green(index: int, button_state: ButtonState) -> void:
	var row: int = index / width
	var col: int = index % width
	var new_row: int = height - row - 1
	var new_col: int = width - col - 1
	var new_index: int = new_row * width + new_col
	buttons[index] = buttons[new_index]
	buttons[new_index] = button_state

func _activate_black(index: int, _button_state: ButtonState) -> void:
	var row_base: int = (index / width) * width
	var last_state: ButtonState = buttons[row_base + width - 1]
	for i in range(row_base + width - 1, row_base, -1):
		buttons[i] = buttons[i - 1]
	buttons[row_base] = last_state

func _activate_red(_index: int, button_state: ButtonState) -> void:
	for button in buttons:
		if button.color == ButtonState.ButtonColor.BLACK:
			button.color = button_state.color
		elif button.color == ButtonState.ButtonColor.WHITE:
			button.color = ButtonState.ButtonColor.BLACK

func _activate_pink(index: int, _button_state: ButtonState) -> void:
	var row: int = index / width
	var col: int = index % width
	var top: int = row == 0
	var bottom: int = row == height - 1
	var left: int = col == 0
	var right: int = col == width - 1
	var targets: Array[int] = []
	if not top: targets.append(index - width)
	if not top and not right: targets.append(index - width + 1)
	if not right: targets.append(index + 1)
	if not bottom and not right: targets.append(index + width + 1)
	if not bottom: targets.append(index + width)
	if not bottom and not left: targets.append(index + width - 1)
	if not left: targets.append(index - 1)
	if not top and not left: targets.append(index - width - 1)
	var last_state: ButtonState = buttons[targets[-1]]
	for i in range(targets.size() - 2, -1, -1):
		buttons[targets[i + 1]] = buttons[targets[i]]
	buttons[targets[0]] = last_state

func _activate_orange(index: int, button_state: ButtonState) -> void:
	var neighbors: Array[int] = _get_adjacent_positions(index)
	var frequencies: Dictionary[ButtonState.ButtonColor, int] = {}
	for neighbor in neighbors:
		var state: ButtonState = buttons[neighbor]
		frequencies[state.color] = frequencies.get(state.color, 0) + 1
	frequencies.sort()
	var freq_list: Array[Array] = []
	for color in frequencies:
		freq_list.append([color, frequencies[color]])
	freq_list.sort_custom(func (a: Array, b: Array) -> bool: return a[1] > b[1])
	if len(freq_list) == 1 or freq_list[0][1] > freq_list[1][1]:
		button_state.color = freq_list[0][0]

func _get_adjacent_positions(index: int) -> Array[int]:
	var row: int = index / width
	var col: int = index % width
	var out: Array[int] = []
	if row != 0:
		out.append((row - 1) * width + col)
	if row != height - 1:
		out.append((row + 1) * width + col)
	if col != 0:
		out.append(index - 1)
	if col != width - 1:
		out.append(index + 1)
	return out
