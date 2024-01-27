extends Control

@export var node: Node
@onready var mark: ColorRect = $Mark
@onready var pos_label: Label = $PanelContainer/MarginContainer/VBoxContainer/PosLabel
@onready var tween_trans_selector: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TweenTransSelector
@onready var tween_ease_selector: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4/TweenEaseSelector
@onready var rotate_checkbox: CheckBox = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/CheckBox
@onready var rotations_input: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/LineEdit
@onready var seconds_input: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/SecondsInput

var setting_mark = false
var tween_trans_type = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for type in ClassDB.class_get_enum_constants("Tween", "TransitionType"):
		tween_trans_selector.add_item(type)
	tween_trans_selector.select(1)
	for type in ClassDB.class_get_enum_constants("Tween", "EaseType"):
		tween_ease_selector.add_item(type)
	tween_ease_selector.select(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if setting_mark:
		mark.set_position(get_global_mouse_position())


func _input(event):
	if event is InputEventMouseButton and setting_mark:
		mark.set_position(event.position)
		pos_label.text = str("Target: ", mark.position)
		setting_mark = false


func _on_set_mark_button_pressed():
	setting_mark = true

func _on_tween_button_pressed():
	var pos = node.position
	var tween = create_tween().set_parallel()
	tween.set_trans(tween_trans_selector.selected - 1)
	tween.set_ease(tween_ease_selector.selected - 1)
	tween.tween_property(node, "position", mark.position, float(seconds_input.text))
	if rotate_checkbox.button_pressed:
		tween.tween_property(node, "rotation", int(rotations_input.text)*TAU, float(seconds_input.text)).as_relative()
	mark.set_position(pos)
