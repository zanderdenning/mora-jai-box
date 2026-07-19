class_name GoalButton
extends Area3D

signal activated

@onready var mesh: CSGMesh3D = $Model/CSGMesh3D
@onready var icon_mesh: Sprite3D = $Model/Sprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

static var COLOR_ICONS: Dictionary[ButtonState.ButtonColor, Texture] = {
	ButtonState.ButtonColor.GRAY: preload("res://resources/goal_button/color_gray.svg"),
	ButtonState.ButtonColor.WHITE: preload("res://resources/goal_button/color_white.svg"),
	ButtonState.ButtonColor.YELLOW: preload("res://resources/goal_button/color_yellow.svg"),
	ButtonState.ButtonColor.VIOLET: preload("res://resources/goal_button/color_violet.svg"),
	ButtonState.ButtonColor.GREEN: preload("res://resources/goal_button/color_green.svg"),
	ButtonState.ButtonColor.BLACK: preload("res://resources/goal_button/color_black.svg"),
	ButtonState.ButtonColor.RED: preload("res://resources/goal_button/color_red.svg"),
	ButtonState.ButtonColor.PINK: preload("res://resources/goal_button/color_pink.svg"),
	ButtonState.ButtonColor.ORANGE: preload("res://resources/goal_button/color_orange.svg"),
	ButtonState.ButtonColor.BLUE: preload("res://resources/goal_button/color_blue.svg"),
}

var goal: BoardGoal = null
var is_correct: bool = false

func _input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_mask == MouseButtonMask.MOUSE_BUTTON_MASK_LEFT:
			animation_player.play(&"push")
			await animation_player.animation_finished
			activated.emit()

func set_goal(new_goal: BoardGoal) -> void:
	goal = new_goal
	set_correct(false)
	if goal is BoardGoalColor:
		icon_mesh.texture = COLOR_ICONS[goal.color]

func set_correct(correct: bool) -> void:
	is_correct = correct
	if goal is BoardGoalColor:
		((mesh.mesh as CylinderMesh).material as StandardMaterial3D).albedo_color = MoraJaiBoxButton.BUTTON_COLOR_MAP[goal.color if correct else ButtonState.ButtonColor.GRAY]
