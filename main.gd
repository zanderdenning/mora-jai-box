class_name Main
extends Node3D

@onready var box: MoraJaiBox = $MoraJaiBox
@onready var tool_palette: VBoxContainer = %ToolPalette
@onready var color_palette: VBoxContainer = %ColorPalette
@onready var alt_color_palette: VBoxContainer = %AltColorPalette
@onready var edit_toggle: CheckButton = %EditToggle
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var share_button: Button = %ShareButton
@onready var solve_button: Button = %SolveButton
@onready var randomize_button: Button = %RandomizeButton
@onready var editor: Control = %Editor
@onready var solution_text: Label = %SolutionText
@onready var palette_tabs: TabContainer = %PaletteTabs

enum EditorTool {
	COLOR,
	ALT_COLOR,
}

var selected_tool: EditorTool = EditorTool.COLOR
var selected_color: ButtonState.ButtonColor = ButtonState.ButtonColor.GRAY
var selected_alt_color: ButtonState.ButtonColor = ButtonState.ButtonColor.GRAY
var _tool_button_styles: Array[StyleBoxFlat] = []
var _color_button_styles: Array[StyleBoxFlat] = []
var _alt_color_button_styles: Array[StyleBoxFlat] = []
#var _hash_update_callback: JavaScriptObject = JavaScriptBridge.create_callback(_update_from_hash)

func _ready() -> void:
	if OS.get_name() == "Web":
		_update_from_hash()
		#JavaScriptBridge.get_interface("window").onhashchange = _hash_update_callback
	else:
		box.make_random()
	box.button_pressed.connect(_on_button_pressed)
	box.goal_button_pressed.connect(_on_goal_button_pressed)
	edit_toggle.toggled.connect(_toggle_edit)
	share_button.pressed.connect(_copy_link)
	solve_button.pressed.connect(_solve)
	randomize_button.pressed.connect(box.make_random)
	_initialize_palettes()

func _initialize_palettes() -> void:
	for tool: EditorTool in EditorTool.values():
		var style_box: StyleBoxFlat = StyleBoxFlat.new()
		style_box.bg_color = Color.DIM_GRAY
		style_box.border_color = style_box.bg_color
		style_box.set_border_width_all(3)
		_tool_button_styles.append(style_box)
		var button: Button = _create_button_from_style_box(style_box)
		button.expand_icon = true
		button.custom_minimum_size = Vector2(50.0, 50.0)
		#button.icon = GoalButton.COLOR_ICONS[color]
		button.pressed.connect(_set_selected_tool.bind(tool))
		button.pressed.connect(_highlight_selected_tool_stylebox.bind(style_box))
		if tool == selected_tool:
			_highlight_selected_tool_stylebox(style_box)
		tool_palette.add_child(button)
	
	for color: ButtonState.ButtonColor in ButtonState.ButtonColor.values():
		var style_box: StyleBoxFlat = StyleBoxFlat.new()
		style_box.bg_color = MoraJaiBoxButton.BUTTON_COLOR_MAP[color]
		style_box.border_color = style_box.bg_color
		style_box.set_border_width_all(3)
		_color_button_styles.append(style_box)
		var button: Button = _create_button_from_style_box(style_box)
		button.expand_icon = true
		button.custom_minimum_size = Vector2(50.0, 50.0)
		button.icon = GoalButton.COLOR_ICONS[color]
		button.pressed.connect(_set_selected_color.bind(color))
		button.pressed.connect(_highlight_selected_color_stylebox.bind(style_box))
		if color == selected_color:
			_highlight_selected_color_stylebox(style_box)
		color_palette.add_child(button)
	
	for color: ButtonState.ButtonColor in ButtonState.ButtonColor.values():
		var style_box: StyleBoxFlat = StyleBoxFlat.new()
		style_box.bg_color = MoraJaiBoxButton.BUTTON_COLOR_MAP[color]
		style_box.border_color = style_box.bg_color
		style_box.set_border_width_all(3)
		_alt_color_button_styles.append(style_box)
		var button: Button = _create_button_from_style_box(style_box)
		button.expand_icon = true
		button.custom_minimum_size = Vector2(50.0, 50.0)
		button.icon = GoalButton.COLOR_ICONS[color]
		button.pressed.connect(_set_selected_alt_color.bind(color))
		button.pressed.connect(_highlight_selected_alt_color_stylebox.bind(style_box))
		if color == selected_alt_color:
			_highlight_selected_alt_color_stylebox(style_box)
		alt_color_palette.add_child(button)

func _create_button_from_style_box(style_box: StyleBox) -> Button:
	var button: Button = Button.new()
	button.expand_icon = true
	button.custom_minimum_size = Vector2(50.0, 50.0)
	button.add_theme_stylebox_override(&"normal", style_box)
	button.add_theme_stylebox_override(&"pressed", style_box)
	button.add_theme_stylebox_override(&"hover", style_box)
	button.add_theme_stylebox_override(&"disabled", style_box)
	button.add_theme_stylebox_override(&"focus", style_box)
	return button

func _update_from_hash() -> void:
	var page_hash: String = JavaScriptBridge.eval("window.location.search")
	if page_hash.length() > 1:
		var unpadded_b64: String = page_hash.substr(1).replace("-", "+").replace("_", "/").replace(".", "=")
		var padded_b64: String = unpadded_b64 + "=".repeat((4 - (unpadded_b64.length() % 4)) % 4)
		var encoded_state: PackedByteArray = Marshalls.base64_to_raw(padded_b64)
		box.starting_state = BoardState.deserialize(encoded_state)
		box.reset()
	else:
		box.make_random()

func _set_selected_tool(tool: EditorTool) -> void:
	selected_tool = tool
	match tool:
		EditorTool.COLOR:
			palette_tabs.current_tab = 0
		EditorTool.ALT_COLOR:
			palette_tabs.current_tab = 1

func _set_selected_color(color: ButtonState.ButtonColor) -> void:
	selected_color = color

func _set_selected_alt_color(color: ButtonState.ButtonColor) -> void:
	selected_alt_color = color

func _highlight_selected_tool_stylebox(style_box: StyleBoxFlat) -> void:
	for style in _tool_button_styles:
		style.border_color = style.bg_color
	style_box.border_color = Color.WHITE

func _highlight_selected_color_stylebox(style_box: StyleBoxFlat) -> void:
	for style in _color_button_styles:
		style.border_color = style.bg_color
	style_box.border_color = Color.WHITE

func _highlight_selected_alt_color_stylebox(style_box: StyleBoxFlat) -> void:
	for style in _alt_color_button_styles:
		style.border_color = style.bg_color
	style_box.border_color = Color.WHITE

func _on_button_pressed(index: int) -> void:
	match selected_tool:
		EditorTool.COLOR:
			box.board_state.buttons[index].color = selected_color
			box.refresh_buttons()
			box.clear_bad_goal_buttons()
		EditorTool.ALT_COLOR:
			box.board_state.buttons[index].alt_color = selected_alt_color
			box.board_state.buttons[index].stickers |= ButtonState.Sticker.ALT
			box.refresh_buttons()
			box.clear_bad_goal_buttons()

func _on_goal_button_pressed(index: int) -> void:
	match selected_tool:
		EditorTool.COLOR:
			var goal: BoardGoalColor = BoardGoalColor.new()
			goal.color = selected_color
			box.board_state.goals[index] = goal
			box.goal_buttons[index].set_goal(goal)

func _toggle_edit(enabled: bool) -> void:
	box.editing = enabled
	editor.visible = enabled
	if not enabled:
		box.starting_state = box.board_state.create_copy()

func _copy_link() -> void:
	animation_player.play(&"link_copied_fade")
	var serialized: PackedByteArray = box.starting_state.serialize()
	DisplayServer.clipboard_set("http://zanderdenning.github.io/mora-jai-box/?%s" % Marshalls.raw_to_base64(serialized).replace("+", "-").replace("/", "_").replace("=", ""))

func _solve() -> void:
	var solver: Solver = Solver.new()
	var result: bool = solver.solve(box.board_state, 100)
	if not result:
		solution_text.text = "No solution found within 100 moves"
	elif solver.solution.is_empty():
		solution_text.text = "Already solved"
	else:
		var string_array: PackedStringArray = PackedStringArray()
		for e in solver.solution:
			string_array.append(str(e))
		solution_text.text = "%d moves: %s" % [string_array.size(), " ".join(string_array)]
