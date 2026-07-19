class_name MoraJaiBoxButton
extends Area3D

signal activated

static var BUTTON_COLOR_MAP: Dictionary[ButtonState.ButtonColor, Color] = {
	ButtonState.ButtonColor.GRAY: Color.DIM_GRAY,
	ButtonState.ButtonColor.WHITE: Color.LIGHT_GRAY,
	ButtonState.ButtonColor.YELLOW: Color.GOLD,
	ButtonState.ButtonColor.VIOLET: Color.DARK_VIOLET,
	ButtonState.ButtonColor.GREEN: Color.WEB_GREEN,
	ButtonState.ButtonColor.BLACK: Color(0.1, 0.1, 0.1),
	ButtonState.ButtonColor.RED: Color.DARK_RED,
	ButtonState.ButtonColor.PINK: Color.HOT_PINK,
	ButtonState.ButtonColor.ORANGE: Color.DARK_ORANGE,
	ButtonState.ButtonColor.BLUE: Color.MEDIUM_BLUE,
}

@onready var mesh: CSGMesh3D = $Model/CSGMesh3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var color: ButtonState.ButtonColor = ButtonState.ButtonColor.GRAY

func _input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_mask == MouseButtonMask.MOUSE_BUTTON_MASK_LEFT:
			animation_player.play(&"push")
			await animation_player.animation_finished
			activated.emit()

func set_color(new_color: ButtonState.ButtonColor) -> void:
	color = new_color
	var mat: StandardMaterial3D = (mesh.mesh as BoxMesh).material
	mat.albedo_color = BUTTON_COLOR_MAP[new_color]

func set_state(new_state: ButtonState) -> void:
	set_color(new_state.color)
