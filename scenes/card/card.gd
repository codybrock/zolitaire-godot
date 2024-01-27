class_name Card
extends Node2D

@onready var card_sprite: Sprite2D = $CardSprite
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var card_area: Area2D = $CardArea2D
@onready var overlap_area: Area2D = $OverlapArea2D

@export var suit = 0
@export var rank = 0

var mouse_over: bool = false
var floating: bool = false
var origin_pos: Vector2

var seen = []


# Called when the node enters the scene tree for the first time.
func _ready():
	card_sprite.frame_coords.x = rank
	card_sprite.frame_coords.y = suit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_over:
		card_sprite.modulate = Color(1.25, 1.25, 1.25)
	else:
		card_sprite.modulate = Color.WHITE


func _on_area_2d_mouse_entered():
	mouse_over = true


func _on_area_2d_mouse_exited():
	mouse_over = false


func _input(event):
	# card currently held?
	if floating:
		# drag along with mouse
		if event is InputEventMouseMotion:
			position += event.relative
		# drop, end floating and animate descent
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			floating = false
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_IN)
			tween.tween_property(card_sprite, "position", Vector2(0, 0), .25)
	# Mouse interactions
	if mouse_over:
		# Left click, start float
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not floating:
				if not recursive_check_stacked():
					#while get_parent() is Card:
						#reparent(get_parent().get_parent())
					floating = true
					origin_pos = event.position
					var tween = create_tween()
					tween.set_trans(Tween.TRANS_BACK)
					tween.set_ease(Tween.EASE_OUT)
					tween.tween_property(card_sprite, "position", Vector2(5, -5), .25)


func _on_overlap_area_2d_area_entered(area: Area2D):
	if not floating:
		return
	
	# figure out which card you're going to land on if you release mouse


func recursive_check_stacked():
	print(get_children().size())
	for child in get_children():
		if child is Card:
			print("child is card")
			return child.recursive_check_stacked()
	return false
		
