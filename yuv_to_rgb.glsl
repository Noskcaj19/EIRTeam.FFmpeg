#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Our textures
layout(r8, set = 0, binding = 0) uniform restrict readonly image2D tex_y;
layout(r8, set = 1, binding = 0) uniform restrict readonly image2D tex_u;
layout(r8, set = 2, binding = 0) uniform restrict readonly image2D tex_v;
layout(rgba8, set = 3, binding = 0) uniform restrict writeonly image2D output_image;

// The code we want to execute in each invocation
void main() {
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 uv_chroma = ivec2(gl_GlobalInvocationID.xy) / 2;

	float y = imageLoad(tex_y, uv).r;
	vec2 chroma;
	chroma.r = imageLoad(tex_u, uv_chroma).r;
	chroma.g = imageLoad(tex_v, uv_chroma).r;
	float u = chroma.r - 0.5;
	float v = chroma.g - 0.5;
	vec3 rgb;
	rgb.r = y + (1.403 * v);
	rgb.g = y - (0.344 * u) - (0.714 * v);
	rgb.b = y + (1.770 * u);
	imageStore(output_image, uv, vec4(rgb, 1.0));
}