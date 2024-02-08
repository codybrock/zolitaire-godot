extends Line2D


var default_font = ThemeDB.fallback_font
#var default_font_size = ThemeDB.fallback_font_size
var font_size = 8


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _draw():
	var points = []
	var parent = get_parent()
	var gparent = parent.get_parent()
	if parent is Card:
		var vec_parent = to_local(parent.global_position) + Vector2(-26, -40)
		if gparent is Card:
			var vec_gparent = to_local(gparent.global_position) + Vector2(-26, -40)
			draw_line(vec_parent, vec_gparent, Color.LIME_GREEN, true)
			
			draw_circle(vec_parent, 4, Color.SEA_GREEN)
			draw_string(default_font, vec_parent + Vector2(10,3), parent.name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			
			draw_circle(vec_gparent, 2, Color.GREEN_YELLOW)
			parent = parent.get_parent()
		else:
			draw_string(default_font, vec_parent + Vector2(10,3), parent.name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			
