// Background shader using the current iced.shader API.
// riced supplies `@fragment fn fs_main`'s vertex stage and the `riced` uniforms.
@fragment
fn fs_main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {
    let aspect = vec2<f32>(riced.resolution.x / max(riced.resolution.y, 1.0), 1.0);
    let p = (uv - vec2<f32>(0.5)) * aspect;
    let t = riced.time * 0.8;
    let v = sin(p.x * 9.0 + t)
        + sin(p.y * 11.0 - t * 0.7)
        + sin(length(p) * 14.0 - t * 1.3);
    let color = 0.5 + 0.5 * cos(v + vec3<f32>(0.0, 2.0, 4.0));
    return vec4<f32>(color, riced.opacity);
}
