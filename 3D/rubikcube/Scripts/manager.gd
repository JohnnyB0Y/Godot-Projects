class_name CubeManager


const FaceType = Cube.FaceType

enum RotateAxis {
	NONE, # 无效的
	# CW 顺时针; CCW 逆时针;
	xCW, xCCW,
	yCW, yCCW,
	zCW, zCCW
}

func is_near_target(value: float, target: float) -> bool:
	return value < target + 0.1 and value > target - 0.1


func is_near_zero(value: float) -> bool:
	return is_near_target(value, 0.0)


# 生成魔方 - 方块数组
func generating_rubik_cube() -> Array[CubeModel]:
	var models: Array[CubeModel] = []
	
	for i in range(3):
		for j in range(9):
			var model = CubeModel.new()
			models.append(model)
			
			match i: # Z轴
				0:
					model.origin.z = 1
					model.faces.append(FaceType.FRONT)
				2:
					model.origin.z = -1
					model.faces.append(FaceType.BACK)
					
			if j < 3: # Y轴
				model.origin.y = 1
				model.faces.append(FaceType.TOP)
			elif j >= 6:
				model.origin.y = -1
				model.faces.append(FaceType.BOTTOM)
			
			match j % 3:
				0:
					model.origin.x = -1
					model.faces.append(FaceType.LEFT)
				2:
					model.origin.x = 1
					model.faces.append(FaceType.RIGHT)
			
	return models


# 计算正方体的旋转类型
func compute_rotate_axis(origin: Vector3, other: Vector3, faceType: FaceType) -> RotateAxis:
	# 判断无效的数据
	var valid: int = 0
	if is_near_zero(origin.y - other.y):
		valid += 1
	if is_near_zero(origin.x - other.x):
		valid += 1
	if is_near_zero(origin.z - other.z):
		valid += 1
		
	if valid != 2:
		return RotateAxis.NONE
		
	if is_near_zero(origin.x - other.x) == false: # X轴平行
		var right_2_left = origin.x - other.x > 0.0 # 右 -> 左
		match faceType:
			FaceType.FRONT:
				return RotateAxis.yCW if right_2_left else RotateAxis.yCCW
			FaceType.BACK:
				return RotateAxis.yCCW if right_2_left else RotateAxis.yCW
			FaceType.TOP:
				return RotateAxis.zCW if right_2_left else RotateAxis.zCCW
			FaceType.BOTTOM:
				return RotateAxis.zCCW if right_2_left else RotateAxis.zCW
		
	elif is_near_zero(origin.y - other.y) == false: # Y轴平行
		var top_2_bottom = origin.y - other.y > 0.0 # top -> bottom
		match faceType:
			FaceType.FRONT:
				return RotateAxis.xCW if top_2_bottom else RotateAxis.xCCW
			FaceType.BACK:
				return RotateAxis.xCCW if top_2_bottom else RotateAxis.xCW
			FaceType.LEFT:
				return RotateAxis.zCW if top_2_bottom else RotateAxis.zCCW
			FaceType.RIGHT:
				return RotateAxis.zCCW if top_2_bottom else RotateAxis.zCW
	
	elif is_near_zero(origin.z - other.z) == false: # Z轴平行
		var front_2_back = origin.z - other.z > 0.0 # front -> back
		match faceType:
			FaceType.TOP:
				return RotateAxis.xCCW if front_2_back else RotateAxis.xCW
			FaceType.BOTTOM:
				return RotateAxis.xCW if front_2_back else RotateAxis.xCCW
			FaceType.LEFT:
				return RotateAxis.yCW if front_2_back else RotateAxis.yCCW
			FaceType.RIGHT:
				return RotateAxis.yCCW if front_2_back else RotateAxis.yCW
		
	return RotateAxis.NONE
