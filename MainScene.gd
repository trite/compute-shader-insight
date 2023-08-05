extends Control

var shaderPath = "res://get_glsl_globals.glsl"

var rd := RenderingServer.create_local_rendering_device()
var shader := rd.shader_create_from_spirv(load(shaderPath).get_spirv())

var shader_local_x = 5
var shader_local_y = 1
var shader_local_z = 1

var shader_groups_x = 1
var shader_groups_y = 1
var shader_groups_z = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_get_info_pressed():
	# How many iterations are going to be run
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

	$VBoxContainer/TextEdit.text = str(result)
