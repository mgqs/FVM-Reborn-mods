// 释放列表离屏表面，避免每次开关面板泄漏一张 720x384 的纹理
if (surface_exists(view_surf)) surface_free(view_surf);
view_surf = -1;
