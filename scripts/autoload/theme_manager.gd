extends Node

var pixel_font: Font
var theme: Theme

# Color palette
const BG_DARK := Color("1a1a2e")
const BG_MID := Color("16213e")
const ACCENT := Color("e94560")
const ACCENT_DARK := Color("c81e45")
const BORDER := Color("0f3460")
const TEXT_COLOR := Color("eaeaea")
const TEXT_DIM := Color("8892a0")

func _ready():
	_load_font()
	_build_theme()
	get_tree().root.theme = theme

func _load_font():
	pixel_font = load("res://assets/fonts/zpix.ttf")

func _build_theme():
	theme = Theme.new()

	# Default font for all types
	theme.set_default_font(pixel_font)
	theme.set_default_font_size(16)

	# --- Button ---
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = BG_MID
	btn_normal.border_color = BORDER
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(0)
	btn_normal.set_content_margin_all(12)

	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = Color("1e2d4a")
	btn_hover.border_color = ACCENT
	btn_hover.set_border_width_all(2)
	btn_hover.set_corner_radius_all(0)
	btn_hover.set_content_margin_all(12)

	var btn_pressed := StyleBoxFlat.new()
	btn_pressed.bg_color = ACCENT_DARK
	btn_pressed.border_color = ACCENT
	btn_pressed.set_border_width_all(2)
	btn_pressed.set_corner_radius_all(0)
	btn_pressed.set_content_margin_all(12)

	var btn_disabled := StyleBoxFlat.new()
	btn_disabled.bg_color = Color("111827")
	btn_disabled.border_color = Color("2a3450")
	btn_disabled.set_border_width_all(2)
	btn_disabled.set_corner_radius_all(0)
	btn_disabled.set_content_margin_all(12)

	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_color("font_color", "Button", TEXT_COLOR)
	theme.set_color("font_hover_color", "Button", ACCENT)
	theme.set_color("font_pressed_color", "Button", TEXT_COLOR)
	theme.set_color("font_disabled_color", "Button", TEXT_DIM)
	theme.set_font_size("font_size", "Button", 16)

	# --- Panel / PanelContainer ---
	var panel_bg := StyleBoxFlat.new()
	panel_bg.bg_color = Color("1a1a2e", 0.85)
	panel_bg.border_color = ACCENT
	panel_bg.set_border_width_all(2)
	panel_bg.set_corner_radius_all(0)
	panel_bg.set_content_margin_all(16)

	theme.set_stylebox("panel", "Panel", panel_bg)
	theme.set_stylebox("panel", "PanelContainer", panel_bg)

	# --- LineEdit ---
	var le_normal := StyleBoxFlat.new()
	le_normal.bg_color = Color("0d1117")
	le_normal.border_color = BORDER
	le_normal.set_border_width_all(2)
	le_normal.set_corner_radius_all(0)
	le_normal.set_content_margin_all(8)

	var le_focus := StyleBoxFlat.new()
	le_focus.bg_color = Color("0d1117")
	le_focus.border_color = ACCENT
	le_focus.set_border_width_all(2)
	le_focus.set_corner_radius_all(0)
	le_focus.set_content_margin_all(8)

	theme.set_stylebox("normal", "LineEdit", le_normal)
	theme.set_stylebox("focus", "LineEdit", le_focus)
	theme.set_color("font_color", "LineEdit", TEXT_COLOR)
	theme.set_color("caret_color", "LineEdit", ACCENT)
	theme.set_font_size("font_size", "LineEdit", 16)

	# --- OptionButton ---
	var opt_normal := StyleBoxFlat.new()
	opt_normal.bg_color = BG_MID
	opt_normal.border_color = BORDER
	opt_normal.set_border_width_all(2)
	opt_normal.set_corner_radius_all(0)
	opt_normal.set_content_margin_all(8)

	var opt_hover := StyleBoxFlat.new()
	opt_hover.bg_color = Color("1e2d4a")
	opt_hover.border_color = ACCENT
	opt_hover.set_border_width_all(2)
	opt_hover.set_corner_radius_all(0)
	opt_hover.set_content_margin_all(8)

	theme.set_stylebox("normal", "OptionButton", opt_normal)
	theme.set_stylebox("hover", "OptionButton", opt_hover)
	theme.set_stylebox("pressed", "OptionButton", opt_hover)
	theme.set_color("font_color", "OptionButton", TEXT_COLOR)
	theme.set_color("font_hover_color", "OptionButton", ACCENT)
	theme.set_font_size("font_size", "OptionButton", 16)

	# --- Label ---
	theme.set_color("font_color", "Label", TEXT_COLOR)
	theme.set_font_size("font_size", "Label", 16)

	# --- HSeparator ---
	var sep_style := StyleBoxLine.new()
	sep_style.color = BORDER
	sep_style.thickness = 1
	theme.set_stylebox("separator", "HSeparator", sep_style)

	# --- ScrollContainer ---
	var scroll_bg := StyleBoxFlat.new()
	scroll_bg.bg_color = Color("0d1117", 0.5)
	scroll_bg.set_corner_radius_all(0)
	theme.set_stylebox("panel", "ScrollContainer", scroll_bg)
