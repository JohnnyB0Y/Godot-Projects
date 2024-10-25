extends Node3D

var _dragging: bool = false

@onready var rubik_cube: MeshInstance3D = $MeshInstance3D
@onready var background: MeshInstance3D = $Background

func _ready() -> void:
	background.visible = true
	rubik_cube.rotate_y(deg_to_rad(45))
	rubik_cube.rotate_x(deg_to_rad(30))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		var screenS = DisplayServer.window_get_size()
		var cubeS = screenS.y * 0.85
		var cubeX = (screenS.x - cubeS) * 0.5
		var cubeY = (screenS.y - cubeS) * 0.5
		var posX = event.position.x
		var posY = event.position.y
		
		if (posX>cubeX and posX<cubeX+cubeS) and (posY>cubeY and posY<cubeY+cubeS):
			if not _dragging and event.pressed:
				_dragging = true
		if _dragging and not event.pressed:
			_dragging = false
			
	if event is InputEventMouseMotion:
		if _dragging:
			rubik_cube.rotate_x(deg_to_rad(event.screen_relative.y * 0.4))
			rubik_cube.rotate_y(deg_to_rad(event.screen_relative.x * 0.4))
