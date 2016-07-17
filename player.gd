extends Node2D

const SPEED = 100

var path = []
var selected = false


func _ready():
	set_fixed_process(true)
	set_process_unhandled_input(true)

func _fixed_process(delta):
	if path.size() > 0:
		var dist = path[0] - get_global_pos()
		play_animation_for_direction(dist.normalized())
		var velocity = dist.normalized() * SPEED
		translate(velocity * delta)
		if dist.length() < 2:
			path.pop_front()
	else:
		play_animation_for_direction(Vector2())

	update()

func play_animation_for_direction(direction):
	var player = get_node("Sprite/AnimationPlayer")
	var animation_name = "idle"
	if direction.x > 0 and direction.y > 0:
		animation_name = "walk_down_right"
	elif direction.x > 0 and direction.y < 0:
		animation_name = "walk_up_right"
	elif direction.x < 0 and direction.y > 0:
		animation_name = "walk_down_left"
	elif direction.x < 0 and direction.y < 0:
		animation_name = "walk_up_left"
	
	if player.get_current_animation() != animation_name:
		player.play(animation_name)

func _draw():
	if path.size() > 1:
		for i in range(1, path.size()):
			var p1 = path[i - 1] - get_global_pos()
			var p2 = path[i] - get_global_pos()
			draw_line(p1, p2, Color(0, 1, 0))
	if selected:
		draw_circle(get_pos() - get_global_pos(), 10, Color(0, 0, 1))

func _unhandled_input(event):
	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed():
		var dist = (get_global_mouse_pos() - get_global_pos()).length()
		if dist < 30:
			selected = true
		else:
			selected = false
	elif event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_RIGHT and event.is_pressed():
		if selected:
			var destination = get_global_mouse_pos()
			path = get_node("../NavigationNode").find_best_path(get_global_pos(), destination)