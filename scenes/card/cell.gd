class_name Cell extends Node2D

@onready var cell_sprite: Sprite2D = $CellSprite

var variant: int


# Called when the node enters the scene tree for the first time.
func _ready():
	set_variant(5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_variant(v: int):
	if v not in range(1, 6):
		return
	variant = v
	cell_sprite.frame = variant
