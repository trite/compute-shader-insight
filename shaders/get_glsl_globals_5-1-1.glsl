#[compute]
#version 450

layout(local_size_x = 5, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer TestBuffer {
  float data[];
} test_buffer;

// The code we want to execute in each invocation
void main() {
  // int global_index = gl_GlobalInvocationID.x + gl_GlobalInvocationID.y * local_size_x;
  // test_buffer.data[global_index] = global_index;
  test_buffer.data[gl_LocalInvocationIndex] = gl_LocalInvocationIndex;
}