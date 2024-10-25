class_name Cube extends Node3D


# 滑动提示信号
signal sliding_hint(model: CubeModel, ended: bool)

# 每个面的颜色类别设置枚举
enum FaceType { FRONT = 0, BACK, LEFT, RIGHT, TOP, BOTTOM, BODY }

const RotateAxis = CubeManager.RotateAxis

# shader 参数数组
const PARAMETER_NAMES = [
	"front_color", "back_color",
	"left_color", "right_color",
	"top_color", "bottom_color",
	"body_color"
]

# shader 颜色数组
const PARAMETER_COLORS = [
	Color.YELLOW, Color.WHITE,
	Color.RED, Color.DARK_ORANGE,
	Color.DARK_BLUE, Color.GREEN,
	Color.DARK_GRAY
]

# 外部传入的模型
var model: CubeModel: set = setup_model

# 正在动画?
var _animating: bool = false
# 半径
var _radius: float
# 旋转动画时长
var _duration: float = 0.35
# 旋转时待更新的角度值
var _update_degrees: float = 0.0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	for key in FaceType.values():
		setup_shader_parameter_for(key, Color.BLACK)


func setup_model(value: CubeModel) -> void:
	model = value
	position = model.origin
	
	for face in model.faces:
		setup_shader_parameter_for(face)


func setup_shader_parameter_for(type: FaceType, value=null):
	var material = mesh_instance_3d.mesh.surface_get_material(0)
	var key = PARAMETER_NAMES[type]
	var newValue = value if value != null else PARAMETER_COLORS[type]
	material.set_shader_parameter(key, newValue)

func rotate_cube_by_angle(degrees: float, rotateAxis: RotateAxis) -> void:
	if _animating:
		return
		
	_animating = true
	
	var curPos: Vector2
	match rotateAxis:
		RotateAxis.zCW, RotateAxis.zCCW:
			curPos = Vector2(position.x, position.y)
		RotateAxis.yCW, RotateAxis.yCCW:
			curPos = Vector2(position.x, position.z)
		_:
			curPos = Vector2(position.y, position.z) 
			
	match rotateAxis:
		RotateAxis.xCCW, RotateAxis.yCCW, RotateAxis.zCCW:
			degrees = -degrees
			
	_radius = curPos.length()
	
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	tw.set_parallel(true)
	
	var curRad = curPos.angle()
	var tarRad = deg_to_rad(rad_to_deg(curRad) + degrees)
	tw.tween_method(_rotate_position_by.bind(rotateAxis), curRad, tarRad, _duration)
	tw.tween_method(_rotate_angle_by.bind(rotateAxis), 0.0, degrees, _duration)
	
	tw.chain()
	tw.tween_callback(_tween_finished)


func _rotate_position_by(radians: float, rotateAxis: RotateAxis) -> void:
	var x = cos(radians) * _radius
	var y = sin(radians) * _radius
	match rotateAxis:
		RotateAxis.zCW, RotateAxis.zCCW:
			position.x = x
			position.y = y
		RotateAxis.yCW, RotateAxis.yCCW:
			position.x = x
			position.z = y
		_:
			position.y = x
			position.z = y


func _rotate_angle_by(degrees: float, rotateAxis: RotateAxis) -> void:
	var addDegrees = degrees - _update_degrees
	_update_degrees += addDegrees
	
	match rotateAxis:
		RotateAxis.zCW, RotateAxis.zCCW:
			rotate_z(deg_to_rad(addDegrees))
		RotateAxis.yCW, RotateAxis.yCCW:
			rotate_y(deg_to_rad(-addDegrees))
		_:
			rotate_x(deg_to_rad(addDegrees))


func _tween_finished() -> void:
	_animating = false
	_update_degrees = 0.0


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			model.temp_pos = position
			sliding_hint.emit(model, event.pressed == false)
			#print("点击" if event.pressed else "松开!")
