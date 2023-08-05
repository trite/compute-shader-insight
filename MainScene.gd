extends Control

var shaders_folder = "res://shaders/"

var rd := RenderingServer.create_local_rendering_device()

var shader_local_x = 42
var shader_local_y = 1
var shader_local_z = 1

var shader_groups_x = 1
var shader_groups_y = 1
var shader_groups_z = 1

var shaders = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = DirAccess.open(shaders_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".glsl"):
				shaders.append(file_name)
				$VBox/HBox/ShaderList.add_item(file_name)
			file_name = dir.get_next()
	else:
		push_error("Problem loading list of shaders from shaders folder")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_get_info_pressed():
	var shader_name = $VBox/HBox/ShaderList.text
	var shader_path = shaders_folder + shader_name

	var regex_str = "get_glsl_globals_(?<x_count>\\d+)-(?<y_count>\\d+)-(?<z_count>\\d+)\\.glsl"
	var regex = RegEx.new()
	regex.compile(regex_str)

	var regex_result = regex.search(shader_name)

	if regex_result:
		shader_local_x = int(regex_result.get_string("x_count"))
		shader_local_y = int(regex_result.get_string("y_count"))
		shader_local_z = int(regex_result.get_string("z_count"))
	else:
		push_error("Problem parsing shader name")
	
	shader_groups_x = int($VBox/HBox/xWorkgroupsValue.text)
	shader_groups_y = int($VBox/HBox/yWorkgroupsValue.text)
	shader_groups_z = int($VBox/HBox/zWorkgroupsValue.text)

	# for n in regex_result.names:
	# 	print(n + ": " + regex_result.get_string(n))

	# regex: get_glsl_globals_(?<x_count>\d+)-(?<y_count>\d+)-(?<z_count>\d+)\.glsl

	# var attempt_load = load(temp_shader_name)
	# var attempt_load = load(simple_shader_path)
	# print(attempt_load)
	# var attempt_get_spirv = attempt_load.get_spirv()

	var shader := rd.shader_create_from_spirv(load(shader_path).get_spirv())

	# # How many iterations are going to be run
	var iterations = \
		shader_local_x \
		* shader_local_y \
		* shader_local_z \
		* shader_groups_x \
		* shader_groups_y \
		* shader_groups_z

	# Create an empty float32 array with length equal to the iteration count
	var data = []
	data.resize(iterations)
	data.fill(0)

	# Create the buffer and uniform so we can send and receive data
	var test_buffer_data = PackedFloat32Array(data)
	var test_buffer_data_bytes = test_buffer_data.to_byte_array()
	var test_buffer = rd.storage_buffer_create(test_buffer_data_bytes.size(), test_buffer_data_bytes)
	var test_uniform = RDUniform.new()
	test_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	test_uniform.binding = 0 # Assign a new binding
	test_uniform.add_id(test_buffer)

	# Add uniforms to a uniform set that will be passed to the shader
	var uniform_set := rd.uniform_set_create([
		test_uniform
	], shader, 0)

	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, shader_groups_x, shader_groups_y, shader_groups_z)
	rd.compute_list_end()

	# Submit to GPU and wait for sync
	# TODO: Docs say that we shouldn't normally sync here,
	#         so figure that out at some point
	rd.submit()
	rd.sync()

	# Read back the data from the buffer
	var result = rd.buffer_get_data(test_buffer).to_float32_array()

	$VBox/HBoxBottom/TextEdit.text = str(result)

