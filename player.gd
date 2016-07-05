
extends KinematicBody2D

var velocity = Vector2()
var points = []
const speed = 100

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	points = get_node("../Navigation2D").get_simple_path(get_global_pos(), get_global_mouse_pos(), false)
	if points.size() >= 1:
		velocity = (points[1] - get_global_pos()).normalized()

	var motion = velocity * speed * delta
	move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
	
	update()

func _draw():
	if points.size() > 1:
		for p in points:
			draw_circle(p - get_global_pos(), 8, Color(1, 0, 0))