class_name CubeModel


var origin: Vector3 = Vector3.ZERO
var faces: Array[Cube.FaceType] = []

# 记录位置, 用于计算旋转方向
var temp_pos: Vector3
