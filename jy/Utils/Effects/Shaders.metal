#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                             constant float2 *vertices [[buffer(0)]]) {
    VertexOut out;
    out.position = float4(vertices[vertexID], 0.0, 1.0);
    out.uv = (vertices[vertexID] + float2(1.0)) * 0.5;
    return out;
}

float3 rgb2hsv(float3 c) {
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = mix(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = mix(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 hsv2rgb(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                             constant float &time [[buffer(0)]]) {
    float2 uv = in.uv;
    float2 center = float2(0.5);
    float dist = distance(uv, center);
    
    // Create animated gradient
    float angle = atan2(uv.y - center.y, uv.x - center.x);
    float offset = sin(time * 0.5) * 0.1;
    
    // Base color in HSV
    float3 hsv = float3(
        fract(angle / (2.0 * M_PI_F) + time * 0.1 + offset),
        0.6 + sin(time * 0.2) * 0.1,
        0.9
    );
    
    // Convert to RGB
    float3 rgb = hsv2rgb(hsv);
    
    // Add some variation based on distance from center
    float alpha = smoothstep(1.0, 0.0, dist * 2.0);
    alpha *= 0.7 + sin(time + dist * 10.0) * 0.3;
    
    return float4(rgb, alpha);
} 

float2 wave(float2 position, float phase) {
    float amplitude = 10.0;
    float frequency = 5.0;
    float2 offset = float2(
        sin(position.y * frequency + phase) * amplitude,
        sin(position.x * frequency + phase) * amplitude
    );
    return position + offset;
}
