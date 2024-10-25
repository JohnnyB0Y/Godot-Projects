shader_type spatial;
render_mode specular_toon;

// 开放每个立方体的面,供外界设置
uniform vec3 front_color  : source_color = vec3(1.0, 1.0, 0.0);
uniform vec3 back_color   : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 left_color   : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 right_color  : source_color = vec3(1.0, 0.2, 0.0);
uniform vec3 top_color    : source_color = vec3(0.0, 0.3, 1.0);
uniform vec3 bottom_color : source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 body_color   : source_color = vec3(0.0, 0.0, 0.0);

// 开放面和边的高亮设置
uniform bool face_light   = false;
uniform bool border_light = false;

// 预设在像素函数中使用的面和边的切分方法,用常量节省性能!
const float borderX = 0.1 / 6.0;
const float borderY = 0.1 / 4.0;
const float faceW = 0.3;
const float faceH = 0.45;

// face 开始 和 结束 的 X Y 位置
const float f1_startX = borderX;
const float f1_endX = f1_startX + faceW;
const float f1_startY = borderY;
const float f1_endY = f1_startY + faceH;

const float f2_startX = f1_endX + 2.0 * borderX;
const float f2_endX = f2_startX + faceW;
const float f2_startY = f1_endY + 2.0 * borderY;
const float f2_endY = f2_startY + faceH;

const float f3_startX = f2_endX + 2.0 * borderX;
const float f3_endX = f3_startX + faceW;

// 数值在范围内吗?
bool isInRange(float val, float start, float end) {
	return val > start && val < end;
}

// 片段着色方法
void fragment() {
	// 边缘
	RIM = 0.2;
	// 金属性
	METALLIC = 0.0;
	// 粗糙度
	ROUGHNESS = 0.01;
	
	// default color
	vec3 pixel_color = body_color;
	bool is_border = true;
	
	float x = UV.x;
	float y = UV.y;
	
	// front back left right, top, bottom
	if (isInRange(y, f1_startY, f1_endY) || isInRange(y, f2_startY, f2_endY)) {
		if (isInRange(x, f1_startX, f1_endX)) {
			pixel_color = y < 0.5 ? front_color : left_color;
			is_border = false;
			if (face_light) EMISSION = pixel_color;
		}
		
		if (isInRange(x, f2_startX, f2_endX)) {
			pixel_color = y < 0.5 ? right_color : top_color;
			is_border = false;
			if (face_light) EMISSION = pixel_color;
		}
		
		if (isInRange(x, f3_startX, f3_endX)) {
			pixel_color = y < 0.5 ? back_color : bottom_color;
			is_border = false;
			if (face_light) EMISSION = pixel_color;
		}
	}
	
	// 反照率
	ALBEDO = pixel_color;
	
	// 发光
	if (border_light && is_border) EMISSION = pixel_color;
}
