
extends RigidBody2D

const SPEED = 2000
const TIME_UNIT = 1
const rooms = ["Lobby", "Hallways", "Shower", "Cafe", "Bedroom"]
const needs = ["Hungry", "Dirty", "Sleepy"]
const need_dict = {
	"Hungry": "Cafe",
	"Dirty": "Shower",
	"Sleepy": "Bedroom"
}

var path = []
var selected = false
var destination = null
var time_acc = 0
var satisfaction = 50
var need = needs[randi() % needs.size()]


func _ready():
	set_fixed_process(true)
	set_process_unhandled_input(true)
	var roomLabel = Label.new()
	roomLabel.set_text(need)
	add_child(roomLabel)

func _fixed_process(delta):
	if destination != null:
		if destination.distance_to(get_global_pos()) < 5:
			destination = null
			path = []
		else:
			path = get_node("../Navigation2D").get_simple_path(get_global_pos(), destination, false)

	if path.size() >= 1:
		var dist = path[1] - get_global_pos()
		var impulse = dist.normalized() * SPEED
		apply_impulse(Vector2(), impulse * delta)
	
	if time_acc >= TIME_UNIT:
		tick_time_unit()
		time_acc = 0
	
	time_acc += delta
	update()

func _draw():
	if path.size() > 1:
		for i in range(1, path.size()):
			var p1 = path[i - 1] - get_global_pos()
			var p2 = path[i] - get_global_pos()
			draw_line(p1, p2, Color(0, 1, 0))
	get_node("Satisfaction").set_text("%d" % satisfaction)

func _unhandled_input(event):
	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed():
		var dist = (get_global_mouse_pos() - get_global_pos()).length()
		if dist < 30:
			selected = true
		else:
			selected = false
	elif event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_RIGHT and event.is_pressed():
		if selected:
			destination = get_global_mouse_pos()


func tick_time_unit():
	var satisfy_delta = -1
	
	if get_current_room() == need_to_room(need):
		satisfy_delta += 2
	
	satisfaction += satisfy_delta

func need_to_room(need):
	return need_dict[need]

func check_room(room_node_name):
	var cafe = get_node("../" + room_node_name)
	var mapPos = cafe.world_to_map(get_global_pos())
	return cafe.get_cellv(mapPos) >= 0

func get_current_room():
	for room_name in rooms:
		if check_room(room_name):
			return room_name