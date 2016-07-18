
extends Node2D

var maps = []

func _ready():
	maps = get_tree().get_nodes_in_group("Floors")

func heuristic(a, b):
	return abs(a.x - b.x) + abs(a.y - b.y)

func get_neighbors(pos):
	var offsets = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
	var positions = []
	for offset in offsets:
		var newPos = pos + offset
		if check_movable(newPos):
			positions.append(newPos)
	var potential_offsets = [Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1)]
	for offset in potential_offsets:
		var new_pos = pos + offset
		var between_x = pos + Vector2(offset.x, 0)
		var between_y = pos + Vector2(0, offset.y)
		if check_movable(new_pos) and check_movable(between_x) and check_movable(between_y):
			positions.append(new_pos)
	return positions

func check_movable(pos):
	for map in maps:
		if map.get_cellv(pos) == 3:
			return true
	return false

func a_star_search(from_pos, to_pos):
	var frontier = PriorityQueue.new()
	frontier.push(from_pos, 0)
	var came_from = {}
	var cost_so_far = {}
	came_from[from_pos] = null
	cost_so_far[from_pos] = 0
	
	while not frontier.empty():
		var current = frontier.pop()
		
		if current == to_pos:
			break
		
		for next in get_neighbors(current):
			var new_cost = cost_so_far[current] + 1
			if not cost_so_far.has(next) or new_cost < cost_so_far[next]:
				cost_so_far[next] = new_cost
				var priority = new_cost + heuristic(to_pos, next)
				frontier.push(next, priority)
				came_from[next] = current

	return came_from

func reconstruct_path(came_from, from_pos, to_pos):
	var current = to_pos
	var path = [current]
	while current != from_pos and came_from.has(current):
		current = came_from[current]
		path.append(current)
	path.invert()
	return path

func find_best_path(world_from_pos, world_to_pos):
	var default_map = maps[0]
	var from_pos = default_map.world_to_map(world_from_pos)
	var to_pos = default_map.world_to_map(world_to_pos)
	if not check_movable(to_pos):
		return []
	var frontier = PriorityQueue.new()
	var came_from = a_star_search(from_pos, to_pos)
	var path = reconstruct_path(came_from, from_pos, to_pos)
	var tile_size = default_map.get_cell_size()
	for i in range(path.size()):
		path[i] = default_map.map_to_world(path[i]) + Vector2(tile_size.x / 16, tile_size.y / 2)
	return path


class Heap:
	var _heap_list = [[0, null]]
	var _size = 0
	
	func empty():
		return _size == 0

	func push(element):
		_heap_list.append(element)
		_size = _size + 1
		swapUp(_size)
	
	func pop():
		var ret = _heap_list[1]
		_heap_list[1] = _heap_list[_size]
		_size = _size - 1
		_heap_list.pop_back()
		swapDown(1)
		return ret
	
	func swapUp(i):
		while i / 2 > 0:
			if _heap_list[i][0] < _heap_list[i / 2][0]:
				var temp = _heap_list[i / 2]
				_heap_list[i / 2] = _heap_list[i]
				_heap_list[i] = temp
			i = i / 2
	
	func swapDown(i):
		while (i * 2) <= _size:
			var minElem = minChild(i)
			if _heap_list[i][0] > _heap_list[minElem][0]:
				var temp = _heap_list[i]
				_heap_list[i] = _heap_list[minElem]
				_heap_list[minElem] = temp
			i = minElem
	
	func minChild(i):
		if i * 2 + 1 > _size:
			return i * 2
		else:
			if _heap_list[i * 2][0] < _heap_list[i * 2 + 1][0]:
				return i * 2
			else:
				return i * 2 + 1


class PriorityQueue:
	var _heap = null
	
	func _init():
		_heap = Heap.new()
	
	func empty():
		return _heap.empty()
		
	func push(item, priority):
		_heap.push([priority, item])
	
	func pop():
		return _heap.pop()[1]