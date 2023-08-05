# compute-shader-insight

# Notes while experimenting:
`gl_LocalInvocationIndex` - current id in:
```
for z in 0..local_size_z:
  for y in 0..local_size_y:
    for x in 0..local_size_x:
      gl_LocalInvocationIndex = something between 0 inclusive and local_size_x * y * z exclusive
```

For a compute shader that just does:
```
test_buffer.data[gl_LocalInvocationIndex] = gl_LocalInvocationIndex;
```

The result will be a list of values from 0 to (local_size_x * y * z - 1), and then A lists of the same length that haven't been modified (all 0's), where A is equal to workgroups_x * y * z - 1:

```
Shader: get_glsl_globals_5-1-1.glsl
Local Workgroup Size (x/y/z): (5/1/1)
Global Workgroup Size (x/y/z): (1/1/1)
Total Iterations: 5
Result: 
[0, 1, 2, 3, 4]

Shader: get_glsl_globals_5-5-1.glsl
Local Workgroup Size (x/y/z): (5/5/1)
Global Workgroup Size (x/y/z): (1/1/1)
Total Iterations: 25
Result: 
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]

Shader: get_glsl_globals_5-5-1.glsl
Local Workgroup Size (x/y/z): (5/5/1)
Global Workgroup Size (x/y/z): (2/1/1)
Total Iterations: 50
Result: 
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

Shader: get_glsl_globals_5-5-1.glsl
Local Workgroup Size (x/y/z): (5/5/1)
Global Workgroup Size (x/y/z): (2/2/1)
Total Iterations: 100
Result: 
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```