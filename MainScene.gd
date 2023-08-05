extends Control

var shaderPath = "res://csa_compute_shader.glsl"

var rd := RenderingServer.create_local_rendering_device()
var shader := rd.shader_create_from_spirv(load(shaderPath).get_spirv())

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_get_info_pressed():
