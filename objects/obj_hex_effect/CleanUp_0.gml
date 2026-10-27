// 释放两栏的离屏表面，否则每次开关面板都会漏一张 surface
if (surface_exists(surf_card))  surface_free(surf_card);
if (surface_exists(surf_enemy)) surface_free(surf_enemy);
surf_card  = -1;
surf_enemy = -1;
