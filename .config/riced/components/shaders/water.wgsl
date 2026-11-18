// Animated water caustics using the current iced.shader API.
// The wallpaper image is layered underneath; this shader is a transparent overlay.
// Old `shade`, `params[0]`, mouse ripple, and `sample_image` are not available:
// texture sampling needs a future shader texture binding.
@fragment
fn fs_main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {
    let aspect = vec2<f32>(riced.resolution.x / max(riced.resolution.y, 1.0), 1.0);
    let p = (uv - vec2<f32>(0.5)) * aspect;
    let t = riced.time * riced.speed;

    let a = sin(p.x * 18.0 + t) * cos(p.y * 16.0 - t * 0.7);
    let b = sin((p.x + p.y) * 22.0 - t * 1.3);
    let caustic = 0.5 + 0.5 * a * b;
    let ripple = 0.5 + 0.5 * sin(length(p) * 34.0 - t * 2.2);
    let glow = caustic * caustic * 0.7 + ripple * 0.3;

    let color = mix(
        vec3<f32>(0.015, 0.060, 0.110),
        vec3<f32>(0.200, 0.650, 0.850),
        glow,
    );
    return vec4<f32>(color, riced.opacity);
}
