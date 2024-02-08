class_name former_card
extends Node2D

const WIDTH = 64
const HEIGHT = 96
const STACK_OFFSET_VECTOR = Vector2(0, 16)
const FLOAT_OFFSET_VECTOR = Vector2(5, -5)

@onready var card_sprite: Sprite2D = $CardSprite
@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var card_area: Area2D = $CardArea2D
@onready var full_collision: CollisionShape2D = $CardArea2D/FullCollisionShape
@onready var stacked_collision: CollisionShape2D = $CardArea2D/StackedCollisionShape
@onready var overlap_area: Area2D = $OverlapArea2D

@export var suit = 0
@export var rank = 0

var mouse_over: bool = false
var floating: bool = false
var origin = null
var stacked_card: Card = null


# Called when the node enters the scene tree for the first time.
func _ready():
	card_sprite.frame_coords.x = rank
	card_sprite.frame_coords.y = suit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$LocalPos.text = str(position.x, ",", position.y)
	$GlobalPos.text = str(global_position.x, ",", global_position.y)
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
		input_floating(event)
	# Mouse interactions
	elif mouse_over:
		# Left click, start float
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not floating:
				if not recursive_check_stacked():
					while get_parent() is Card:
						reparent(get_parent().get_parent())
					start_floating()


func input_floating(event):
	var over_areas = overlap_area.get_overlapping_areas()
	print(over_areas)
	for area in over_areas:
		if area.get_parent() != self:
			if area.get_parent().can_stack(self):
				area.get_parent().card_sprite.self_modulate = Color.GOLD
			else:
				area.get_parent().card_sprite.self_modulate = Color.RED
	
	# drag along with mouse
	if event is InputEventMouseMotion:
		position += event.relative
	# drop, end floating and animate descent
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		for area in over_areas:
			var card: Card = area.get_parent()
			if card != self and card.can_stack(self):
				card.stack_card(self)
				stop_floating(true)
				return
		# no stack found, go back to origin
		stop_floating()


func start_floating():
	get_parent().move_child(self, -1)
	floating = true
	origin = get_parent()
	var tween = create_tween().set_parallel()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card_sprite, "position", Vector2(5, -5), .25)
	#tween.tween_property(shadow_sprite, "position", Vector2(-5, 5), .25)
	
	
func stop_floating(revert: bool = false):
	if origin and origin is Card and revert:
		origin.stack_card(self)
	floating = false
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(card_sprite, "position", Vector2(0, 0), .25)


#func _on_overlap_area_2d_area_entered(area: Area2D):
	#print(overlap_area.get_overlapping_areas())
	#if not floating:
		#return
	
	# figure out which card you're going to land on if you release mouse


func recursive_check_stacked():
	print(get_children().size())
	for child in get_children():
		if child is Card:
			print("child is card")
			return child.recursive_check_stacked()
	return false
#
#
func recursive_check_valid_stacked():
	return true


func can_stack(card: Card) -> bool:
	# rules: 
	#  not already stacked
	#  different suit
	#  rank 1 lower
	#  not "ace"
	if not stacked_card:
		if card.suit != suit:
			if card.rank == rank - 1 and card.rank != 0:
				return true
	return false


func stack_card(card: Card):
	stacked_card = card
	add_child(card)
	stacked_card.position = STACK_OFFSET_VECTOR
	stacked_card.stop_floating()
	full_collision.disabled = true
	stacked_collision.disabled = false


func unstack_card() -> Card:
	var card = stacked_card
	stacked_card = null
	remove_child(card)
	full_collision.disabled = true
	stacked_collision.disabled = false
	return card
		

