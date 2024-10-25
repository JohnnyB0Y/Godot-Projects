extends Control


# 计算符号
const cpt_symbols: Array[String] = [
	"+", "-", "x", "/"
]

# 用户输入的字符和数字
var _input_values: Array[String] = []

@onready var label: Label = $Background/Label


# 是否计算符号重复输入
func _is_repeated_cpt_input(value: String) -> bool:
	var last = _input_values.back()
	if last == null and value == "-":
		return false
		
	if value in cpt_symbols:
		if last == null or last in cpt_symbols:
			return true
			
	return false


func _text_from_input_values() -> String:
	var text = ""
	for value in _input_values:
		text += value
	return text


# 处理输入的字符
func _handle_input_values() -> Array[String]:
	var numbers: Array[String] = []
	var number = ""
	for val in _input_values:
		if val in cpt_symbols:
			if not number.is_empty():
				numbers.append(number)
				
			if val in ["x", "/"]:
				numbers.append(val)
				
			number = "-" if val == "-" else ""
		else:
			number += val
			
	if not number.is_empty():
		numbers.append(number)
	
	return numbers


# 计算并返回结果
func _cpt_result(numbers: Array[String]) -> float:
	var stack: Array[String] = []
	while numbers.size() != 0:
		var front = numbers.pop_front()
		if front in ["x", "/"]:
			var num1 = stack.pop_back().to_float()
			var num2 = numbers.pop_front().to_float()
			var result = num1 * num2 if front == "x" else num1 / num2
			stack.append(str(result))
		else:
			stack.append(front)
			
	var result: float = 0
	for num in stack:
		result += num.to_float()
	
	return result


# 按钮点击
func _on_button_pressed(val: String) -> void:
	# 排除非法除零
	if val == "0" and _input_values.back() == "/":
		return
		
	# 按下的是清除按钮
	if val == "c":
		_input_values.clear()
		label.text = "0"
		return
		
	# 非等号处理
	if not val == "=":
		# 重复输入计算符号
		if _is_repeated_cpt_input(val):
			return
		
		# 记录输入的符号包括数字
		_input_values.append(val)
		label.text = _text_from_input_values()
		return
		
	# 等号处理
	# 去除最后多余的计算字符
	if _input_values.back() in cpt_symbols:
		_input_values.pop_back()
	
	# 算数
	var numbers = _handle_input_values()
	var result = _cpt_result(numbers)
	var text = str(result)
	
	# 显示计算结果
	_input_values.clear()
	_input_values.append(text)
	label.text = text
