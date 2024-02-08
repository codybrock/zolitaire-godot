extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_child_count():
		print(get_child(i).name)
	print("---")
	move_child(get_child(0), -1)
	for i in get_child_count():
		prints(get_child(i).name, get_child(i).get_index())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
