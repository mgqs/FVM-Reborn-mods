// Feather disable all
/// Creates a new font with an outline based on a given source font
///
/// @param sourceFontName              Name, as a string, of the font to use as a basis for the effect
/// @param newFontName                 Name of the new font to create, as a string
/// @param shader                      Shader to use
/// @param emptyOutlineSize            Outline around the outside of every output glyph, in pixels. A value of 2 is typical
/// @param leftPad                     Padding around the outside of every *input* glyph. Positive values give more space. e.g. For a shader that adds a outline of 2px around the entire glyph, *all* padding arguments should be set to <2>
/// @param topPad                      "
/// @param rightPad                    "
/// @param bottomPad                   "
/// @param separationDelta             Change in every glyph's SCRIBBLE_GLYPH.SEPARATION value. For a shader that adds a outline of 2px around the entire glyph, this value should be 4px
/// @param smooth                      Set to <true> to turn on linear interpolation
/// @param [surfaceSize=2048]          Size of the surface to use. Defaults to 2048x2048
/// @param [markAsRasterEffect=false]

function scribble_font_bake_shader(_source_font_name, _new_font_name, _shader, _outline, _l_pad, _t_pad, _r_pad, _b_pad, _separation, _smooth, _texture_size = 2048, _markAsRasterEffect = false)
{
    if (!is_string(_source_font_name))
    {
        __scribble_error("Fonts should be specified using their name as a string.\n(Input was an invalid datatype)");
        exit;
    }
    
    if (!is_string(_new_font_name))
    {
        __scribble_error("Fonts should be specified using their name as a string.\n(Input was an invalid datatype)");
        exit;
    }
    
    if (_source_font_name == _new_font_name)
    {
        __scribble_error("Source font and new font cannot share the same name");
        return;
    }

    static _font_data_map = __scribble_system().__font_data_map;
    var _src_font_data = _font_data_map[? _source_font_name];
    if (!is_struct(_src_font_data))
    {
        __scribble_error("Source font \"", _source_font_name, "\" not found\n\"", _new_font_name, "\" will not be available");
        return;
    }
    
    if (_src_font_data.__render_type == __SCRIBBLE_RENDER_RASTER_WITH_EFFECTS)
    {
        __scribble_error("Source font cannot already have effects baked into it");
        return;
    }
    
    if (_src_font_data.__render_type == __SCRIBBLE_RENDER_SDF)
    {
        __scribble_error("Source font cannot be an SDF font");
        return;
    }
    
    if (scribble_font_exists(_new_font_name))
    {
        __scribble_error($"A font called \"{_new_font_name}\" already exists");
        return;
    }
    
    _src_font_data.__ensure_material_textures_fetched();
    _src_font_data.__ensure_texel_data();
    
    var _src_glyph_grid = _src_font_data.__glyph_data_grid;
    var _glyph_count = ds_grid_width(_src_glyph_grid);
    
    // [FVM] 自动扩容：中文字体字形数远超原版假设的容量时（font_hei 目前约 6000 字形），
    // 2048x2048 会装不下并在下面直接 show_error 终止游戏。这里先用同一套行排布算法试算，
    // 按 256 步长找到刚好装得下的边长（上限 8192），仍然不够才交回原逻辑报错。
    var _fit_size = __scribble_bake_autosize(_src_glyph_grid, _glyph_count, _texture_size,
                                              _outline, _l_pad, _t_pad, _r_pad, _b_pad);
    if (_fit_size != _texture_size)
    {
        show_debug_message("[FVM] scribble bake \"" + _new_font_name + "\": texture size "
                         + string(_texture_size) + " -> " + string(_fit_size));
        _texture_size = _fit_size;
    }
    
    //Create a new font
    var _new_font_data = new __scribble_class_font(_new_font_name, _glyph_count, undefined, false, true);
    _new_font_data.__bilinear = _smooth;
    _new_font_data.__runtime  = true;
    var _new_glyphs_grid = _new_font_data.__glyph_data_grid;
    
    //Copy the raw data over from the source font (this include the glyph map, glyph grid, and other assorted properties)
    _src_font_data.__copy_to(_new_font_data, false);
    
    if (_markAsRasterEffect) _new_font_data.__render_type = __SCRIBBLE_RENDER_RASTER_WITH_EFFECTS;
    
    
    
    //We spin up vertex buffers on demand based on what textures are being used
    var _vbuff_data_map = ds_map_create();
    
    var _line_x      = 0;
    var _line_y      = 0;
    var _line_height = 0;
    
    var _i = 0;
    repeat(_glyph_count)
    {
        var _material = _src_glyph_grid[# _i, SCRIBBLE_GLYPH.MATERIAL];
        var _texture = _material.__texture;
        
        if (not texture_is_ready(_texture))
        {
            __scribble_error($"Font \"{_source_font_name}\" texture {string(_texture)} not ready.\nIs the source graphic in an unloaded or unfetched dynamic texture group?\nMaterial debug name:\"{_material.__debug_font_name}\"\nMaterial key:\"{_material.__key}\"");
        }
        
        //Ignore any glyphs with invalid textures
        if (_texture == undefined)
        {
            ++_i;
            continue;
        }
        
        var _width  = _src_glyph_grid[# _i, SCRIBBLE_GLYPH.WIDTH  ];
        var _height = _src_glyph_grid[# _i, SCRIBBLE_GLYPH.HEIGHT ];
        var _u0     = _src_glyph_grid[# _i, SCRIBBLE_GLYPH.U0     ];
        var _v0     = _src_glyph_grid[# _i, SCRIBBLE_GLYPH.V0     ];
        var _u1     = _src_glyph_grid[# _i, SCRIBBLE_GLYPH.U1     ];
        var _v1     = _src_glyph_grid[# _i, SCRIBBLE_GLYPH.V1     ];
        
        var _width_ext  = _width  + _outline + _l_pad + _r_pad;
        var _height_ext = _height + _outline + _t_pad + _b_pad;
        
        //Check to see if we have space on this texture page
        if (_line_y + _height_ext >= _texture_size)
        {
            __scribble_error("No space left on ", _texture_size, "x", _texture_size, " texture page\nPlease increase the size of the texture page");
            vertex_end(_vbuff);
            vertex_delete_buffer(_vbuff);
            return;
        }
        
        //Line wrap glyphs
        if (_line_x + _width_ext >= _texture_size)
        {
            _line_x       = 0;
            _line_y      += _line_height;
            _line_height  = 0;
        }
        
        //Find a vertex buffer for this particular glyph's texture
        var _vbuff_data = _vbuff_data_map[? string(_texture)];
        if (_vbuff_data == undefined)
        {
            static _vertex_format = undefined;
            if (_vertex_format == undefined)
            {
                vertex_format_begin();
                vertex_format_add_position(); //12 bytes
                vertex_format_add_color();    // 4 bytes
                vertex_format_add_texcoord(); // 8 bytes
                _vertex_format = vertex_format_end();
            }
            
            //If we don't have a vertex buffer for this texture, create a new one and store a reference to it
            var _vbuff = vertex_create_buffer();
            vertex_begin(_vbuff, _vertex_format);
            
            _vbuff_data_map[? string(_texture)] = {
                __vertex_buffer: _vbuff,
                __texture: _texture,
            };
        }
        else
        {
            var _vbuff = _vbuff_data.__vertex_buffer;
        }
        
        var _l = _l_pad + _line_x;
        var _t = _t_pad + _line_y;
        var _r = _l + _width;
        var _b = _t + _height;
        
        vertex_position(_vbuff, _l, _t); vertex_color(_vbuff, c_white, 1.0); vertex_texcoord(_vbuff, _u0, _v0);
        vertex_position(_vbuff, _r, _t); vertex_color(_vbuff, c_white, 1.0); vertex_texcoord(_vbuff, _u1, _v0);
        vertex_position(_vbuff, _l, _b); vertex_color(_vbuff, c_white, 1.0); vertex_texcoord(_vbuff, _u0, _v1);
        
        vertex_position(_vbuff, _r, _t); vertex_color(_vbuff, c_white, 1.0); vertex_texcoord(_vbuff, _u1, _v0);
        vertex_position(_vbuff, _r, _b); vertex_color(_vbuff, c_white, 1.0); vertex_texcoord(_vbuff, _u1, _v1);
        vertex_position(_vbuff, _l, _b); vertex_color(_vbuff, c_white, 1.0); vertex_texcoord(_vbuff, _u0, _v1);
            
        _new_glyphs_grid[# _i, SCRIBBLE_GLYPH.U0] = _line_x;
        _new_glyphs_grid[# _i, SCRIBBLE_GLYPH.V0] = _line_y;
        _new_glyphs_grid[# _i, SCRIBBLE_GLYPH.U1] = _line_x + _width  + _l_pad + _r_pad;;
        _new_glyphs_grid[# _i, SCRIBBLE_GLYPH.V1] = _line_y + _height + _t_pad + _b_pad;;
        
        _line_x += _width_ext;
        _line_height = max(_line_height, _height_ext);
        
        ++_i;
    }
    
    //Draw the vertex buffers to a surface, then bake that surface into a sprite
    var _surface_0 = surface_create(_texture_size, _texture_size);
    
    //Draw the source glyphs to a surface
    surface_set_target(_surface_0);
    draw_clear_alpha(c_white, 0.0);
    gpu_set_blendenable(false);
    
    //Iterate over all vertex buffers we created and draw those vertex buffers to the first surface
    var _vbuff_data_array = ds_map_values_to_array(_vbuff_data_map);
    var _i = 0;
    repeat(array_length(_vbuff_data_array))
    {
        var _vbuff_data = _vbuff_data_array[_i];
        var _vbuff = _vbuff_data.__vertex_buffer;
        
        vertex_end(_vbuff);
        vertex_submit(_vbuff, pr_trianglelist, _vbuff_data.__texture);
        vertex_delete_buffer(_vbuff);
        
        ++_i;
    }
    
    ds_map_destroy(_vbuff_data_map);
    var _surface_1 = surface_create(_texture_size, _texture_size);
    
    gpu_set_blendenable(true);
    surface_reset_target();
    
    var _texture = surface_get_texture(_surface_0);
    
    //Draw one surface to another using the shader
    surface_set_target(_surface_1);
    draw_clear_alpha(c_white, 0.0);
    
    var _old_filter = gpu_get_tex_filter();
    gpu_set_tex_filter(_smooth);
    gpu_set_blendenable(false);
    
    shader_set(_shader);
    shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), texture_get_texel_width(_texture), texture_get_texel_height(_texture));
    draw_surface(_surface_0, 0, 0);
    shader_reset();
    
    gpu_set_tex_filter(_old_filter);
    gpu_set_blendenable(true);
    surface_reset_target();
    
    surface_free(_surface_0);
    
    //Make a sprite from the effect surface to make the texture stick
    var _sprite = sprite_create_from_surface(_surface_1, 0, 0, _texture_size, _texture_size, false, false, 0, 0);
    _new_font_data.__source_sprite = _sprite;
    surface_free(_surface_1);
    
    //Create a new material for this font
    var _new_material = __scribble_get_material(_new_font_name, __scribble_sprite_get_texture_index(_sprite, 0), _new_font_data.__render_type, undefined, undefined, _new_font_data.__bilinear);
    
    //Make bulk corrections to various glyph properties based on the input parameters
    ds_grid_add_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.X_OFFSET,    _glyph_count-1, SCRIBBLE_GLYPH.X_OFFSET,    -_l_pad);
    ds_grid_add_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.Y_OFFSET,    _glyph_count-1, SCRIBBLE_GLYPH.Y_OFFSET,    -_t_pad);
    ds_grid_add_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.WIDTH,       _glyph_count-1, SCRIBBLE_GLYPH.WIDTH,       _l_pad + _r_pad);
    ds_grid_add_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.HEIGHT,      _glyph_count-1, SCRIBBLE_GLYPH.HEIGHT,      _t_pad + _b_pad);
    ds_grid_add_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.FONT_HEIGHT, _glyph_count-1, SCRIBBLE_GLYPH.FONT_HEIGHT, _t_pad + _b_pad);
    ds_grid_add_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.SEPARATION,  _glyph_count-1, SCRIBBLE_GLYPH.SEPARATION,  _separation);
    ds_grid_set_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.MATERIAL,    _glyph_count-1, SCRIBBLE_GLYPH.MATERIAL,    _new_material);
    
    //Figure out the new UVs using some bulk commands
    var _sprite_uvs = sprite_get_uvs(_sprite, 0);
    var _sprite_u0 = _sprite_uvs[0];
    var _sprite_v0 = _sprite_uvs[1];
    var _sprite_u1 = _sprite_uvs[2];
    var _sprite_v1 = _sprite_uvs[3];
    
    ds_grid_multiply_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.U0, _glyph_count-1, SCRIBBLE_GLYPH.V1, 1/_texture_size);
    ds_grid_multiply_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.U0, _glyph_count-1, SCRIBBLE_GLYPH.U1, _sprite_u1 - _sprite_u0); //Note we're adjusting U0 and U1 in the same pass
    ds_grid_multiply_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.V0, _glyph_count-1, SCRIBBLE_GLYPH.V1, _sprite_v1 - _sprite_v0); //Note we're adjusting V0 and V1 in the same pass
    ds_grid_add_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.U0, _glyph_count-1, SCRIBBLE_GLYPH.U1, _sprite_u0); //Note we're adjusting U0 and U1 in the same pass
    ds_grid_add_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.V0, _glyph_count-1, SCRIBBLE_GLYPH.V1, _sprite_v0); //Note we're adjusting V0 and V1 in the same pass
    
    //All texels are automatically valid
    ds_grid_set_region(_new_glyphs_grid, 0, SCRIBBLE_GLYPH.TEXELS_VALID, _glyph_count-1, SCRIBBLE_GLYPH.TEXELS_VALID, true);
}

/// [FVM] 选择一个能装下全部字形的烘焙边长（256 步长，最大 8192）。
/// 完全复刻 scribble_font_bake_shader 内部的行排布算法，避免估算偏差。
function __scribble_bake_autosize(_grid, _count, _start_size, _outline, _l_pad, _t_pad, _r_pad, _b_pad)
{
    var _max_size = 8192;
    // 先试原尺寸：绝大多数字体一次就过，不做任何额外计算
    if (__scribble_bake_fits(_grid, _count, _start_size, _outline, _l_pad, _t_pad, _r_pad, _b_pad))
    {
        return _start_size;
    }

    // 不够再按 256 递增（而不是直接翻倍），尽量少占显存
    for (var _size = _start_size + 256; _size <= _max_size; _size += 256)
    {
        if (__scribble_bake_fits(_grid, _count, _size, _outline, _l_pad, _t_pad, _r_pad, _b_pad))
        {
            return _size;
        }
    }
    // 连 8192 都装不下：交回原逻辑报错，至少错误信息是准确的
    return _start_size;
}

/// [FVM] 试算给定边长能否排下全部字形（与烘焙循环判定条件保持一致）
function __scribble_bake_fits(_grid, _count, _size, _outline, _l_pad, _t_pad, _r_pad, _b_pad)
{
    var _line_x = 0;
    var _line_y = 0;
    var _line_height = 0;
    // 底部预留 64px：实际字形的宽高若比字体资源记录的大 1~2px，也不至于刚好压线越界
    var _limit = _size - 64;
    var _i = 0;
    repeat (_count)
    {
        var _material = _grid[# _i, SCRIBBLE_GLYPH.MATERIAL];
        var _texture = _material.__texture;
        if (is_undefined(_texture))
        {
            ++_i;
            continue;
        }

        var _w = _grid[# _i, SCRIBBLE_GLYPH.WIDTH ] + _outline + _l_pad + _r_pad;
        var _h = _grid[# _i, SCRIBBLE_GLYPH.HEIGHT] + _outline + _t_pad + _b_pad;

        // 与原版一致的越界判定，只是底部多留一点余量
        if (_line_y + _h >= _limit) return false;

        if (_line_x + _w >= _size)
        {
            _line_x = 0;
            _line_y += _line_height;
            _line_height = 0;
        }

        _line_x += _w;
        _line_height = max(_line_height, _h);

        ++_i;
    }
    return true;
}
