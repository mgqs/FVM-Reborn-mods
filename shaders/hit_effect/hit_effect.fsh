//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_progress; // 受击进度 (0~1)
uniform vec3 u_flashColor;   // 闪光颜色 (RGB)
uniform float u_intensity; 

void main() {
    // 获取原始纹理颜色
    vec4 base_color = texture2D(gm_BaseTexture, v_vTexcoord);
    
    // 处理非透明像素
    if (base_color.a < 0.01) discard; // 丢弃完全透明像素
    
    // 应用顶点颜色混合
    base_color *= v_vColour;
    
    // 计算闪光强度 (开始=1.0, 结束=0.0)
	
    float flash_intensity =1.0 - clamp(u_progress, 0.0, 1.0);
	
	float u_intensity = 1.0;
	vec3 adjusted_flash = u_flashColor * u_intensity;
    
    // 加法混合
    vec3 final_color = base_color.rgb + adjusted_flash * flash_intensity;
    
    // 保持原始透明度
    gl_FragColor = vec4(final_color, base_color.a);
}