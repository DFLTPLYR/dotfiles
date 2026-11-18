// Wallpaper ripple transition. textures = { previous, current }.
//
// progress comes from extraArgs and runs from 0 to 1. The new wallpaper
// expands from the centre inside a soft, wobbling ripple front.
@fragment
fn fs_main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {
    let aspect = riced.resolution.x / max(riced.resolution.y, 1.0);
    let p = (uv - vec2<f32>(0.5)) * vec2<f32>(aspect, 1.0);
    let distance = length(p);
    let radius = length(vec2<f32>(aspect, 1.0)) * 0.5;
    let progress = clamp(riced.progress, 0.0, 1.0);

    let width = 0.16;
    let front = progress * (radius + width) - width;
    let wave = exp(-pow((distance - front) / width, 2.0));
    let mask = 1.0 - smoothstep(front, front + width, distance);

    let direction = select(
        vec2<f32>(1.0, 0.0),
        p / max(distance, 0.0001),
        distance > 0.0001,
    );
    let wobble = wave * progress * 0.03 * sin(distance * 40.0 - riced.time * 8.0);
    let warped = clamp(uv + direction * wobble, vec2<f32>(0.0), vec2<f32>(1.0));

    let previous = textureSample(riced_texture0, riced_sampler0, warped);
    let current = textureSample(riced_texture1, riced_sampler1, uv);
    let color = mix(previous.rgb, current.rgb, mask);
    let highlight = wave * progress * (1.0 - progress) * 1.2;
    return vec4<f32>(color + vec3<f32>(highlight), 1.0);
}
