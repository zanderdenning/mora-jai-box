class_name MoraJaiBox
extends Node

signal button_pressed(index: int)
signal goal_button_pressed(index: int)

@onready var buttons: Array[MoraJaiBoxButton] = [
	$Buttons/Button11,
	$Buttons/Button12,
	$Buttons/Button13,
	$Buttons/Button21,
	$Buttons/Button22,
	$Buttons/Button23,
	$Buttons/Button31,
	$Buttons/Button32,
	$Buttons/Button33,
]

@onready var goal_buttons: Array[GoalButton] = [
	$Goals/GoalButton0,
	$Goals/GoalButton1,
	$Goals/GoalButton2,
	$Goals/GoalButton3,
]

static func get_goal_index(state: BoardState, i: int) -> int:
	match i:
		0:
			return 0
		1:
			return state.width - 1
		2:
			return state.width * state.height - state.width
		3:
			return state.width * state.height - 1
	return -1

@export var starting_state: BoardState = null
var board_state: BoardState = null
var editing: bool = false

func _ready() -> void:
	for i in buttons.size():
		buttons[i].activated.connect(_on_button_activated.bind(i))
	for i in goal_buttons.size():
		goal_buttons[i].activated.connect(_on_goal_button_activated.bind(i))

func make_random(min_moves: int = 5, max_moves: int = 20) -> void:
	var tries: int = 0
	while true:
		tries += 1
		print(tries)
		var state: BoardState = BoardState.new()
		state.width = 3
		state.height = 3
		for i in state.width * state.height:
			var button_state: ButtonState = ButtonState.new()
			button_state.color = [ButtonState.ButtonColor.WHITE, ButtonState.ButtonColor.GRAY, ButtonState.ButtonColor.BLACK].pick_random()
			state.buttons.append(button_state)
		for i in 4:
			var goal: BoardGoalColor = BoardGoalColor.new()
			goal.color = ButtonState.ButtonColor.WHITE
			state.goals.append(goal)
		var solver: Solver = Solver.new()
		var success: bool = solver.solve(state, max_moves)
		if not success:
			continue
		if solver.solution.size() < min_moves:
			continue
		print("Solution in %d moves" % solver.solution.size())
		print("Visited %d states" % solver.visited_states.size())
		print("Valid puzzle made in %d tries" % tries)
		starting_state = state
		reset()
		return

func _set_state(state: BoardState) -> void:
	board_state = state.create_copy()
	for i in buttons.size():
		buttons[i].set_state(state.buttons[i])
	for i in goal_buttons.size():
		goal_buttons[i].set_goal(state.goals[i])

func reset(refresh: bool = true) -> void:
	_set_state(starting_state)
	if refresh:
		refresh_buttons()

func _on_button_activated(index: int) -> void:
	if editing:
		button_pressed.emit(index)
		return
	board_state.activate_button(index)
	clear_bad_goal_buttons()
	refresh_buttons()

func _on_goal_button_activated(index: int) -> void:
	if editing:
		goal_button_pressed.emit(index)
		return
	if board_state.goals[index].check(board_state, get_goal_index(board_state, index)):
		goal_buttons[index].set_correct(true)
		var all_correct: bool = true
		for goal_button in goal_buttons:
			if not goal_button.is_correct:
				all_correct = false
				break
		if all_correct:
			if OS.get_name() == "Web":
				JavaScriptBridge.eval("confetti()")
	else:
		reset()

func clear_bad_goal_buttons() -> void:
	for i in goal_buttons.size():
		var goal_button: GoalButton = goal_buttons[i]
		if goal_button.is_correct:
			if not board_state.goals[i].check(board_state, get_goal_index(board_state, i)):
				goal_buttons[i].set_correct(false)

func refresh_buttons() -> void:
	for i in board_state.width * board_state.height:
		buttons[i].set_state(board_state.buttons[i])
