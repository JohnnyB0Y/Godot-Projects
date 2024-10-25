class_name RubikCube extends MeshInstance3D

const RAY_LENGTH = 10
const FaceType = Cube.FaceType
const RotateAxis = CubeManager.RotateAxis

# 所有方块
var cubes: Array[Cube] = []
# 方块管理器
var manager: CubeManager = CubeManager.new()

# 旋转的模型数组
var _rotate_models: Array[CubeModel] = []
# 鼠标滑动的表面
var _face: FaceType

@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var audio_player: AudioStreamPlayer = $"../AudioPlayer"


func _ready() -> void:
	var cubeT = preload("res://Scences/cube.tscn")
	var models = manager.generating_rubik_cube()
	for model in models:
		var cube: Cube = cubeT.instantiate()
		cubes.append(cube)
		add_child(cube)
		cube.model = model
		cube.sliding_hint.connect(_handle_sliding_hint)


func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	
	var origin = camera_3d.project_ray_origin(mousepos)
	var end = origin + camera_3d.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collision_mask = 2
	
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		var shape_idx = result["shape"]
		_face = FaceType.values()[shape_idx]
		#print(FaceType.keys()[_face])


func _handle_sliding_hint(model: CubeModel, ended: bool) -> void:
	_rotate_models.append(model)
	if ended:
		_rotate_cubes(_rotate_models)
		_rotate_models.clear()


func _rotate_cubes(models: Array[CubeModel]) -> void:
	var m1 = models.front() as CubeModel
	var m2 = models.back() as CubeModel
	
	var rotateAxis = manager.compute_rotate_axis(m1.temp_pos, m2.temp_pos, _face)
	
	if rotateAxis == RotateAxis.NONE:
		print("无效移动!")
		return
	
	print("旋转方向: ", RotateAxis.keys()[rotateAxis])
	
	var subCubes = []
	for cube: Cube in cubes:
		match rotateAxis:
			RotateAxis.xCW, RotateAxis.xCCW:
				if manager.is_near_zero(m1.temp_pos.x - cube.position.x):
					subCubes.append(cube)
			RotateAxis.yCW, RotateAxis.yCCW:
				if manager.is_near_zero(m1.temp_pos.y - cube.position.y):
					subCubes.append(cube)
			RotateAxis.zCW, RotateAxis.zCCW:
				if manager.is_near_zero(m1.temp_pos.z - cube.position.z):
					subCubes.append(cube)
	
	# 音效
	audio_player.play()
	
	# 动画
	for cube: Cube in subCubes:
		cube.rotate_cube_by_angle(90, rotateAxis)	
