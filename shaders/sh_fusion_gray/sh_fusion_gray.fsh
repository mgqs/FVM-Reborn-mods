//
// 融合页「未拥有」灰显：去色（黑白）+ 轻微压暗
// 用法：shader_set(sh_fusion_gray); draw_sprite_ext(...); shader_reset();
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 c = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));   // Rec.601 亮度
    g *= 0.92;                                          // 再压一点，像图鉴里没拥有的卡
    gl_FragColor = vec4(g, g, g, c.a);
}
