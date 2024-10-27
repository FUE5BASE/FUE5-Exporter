data:extend(
{
	{
		type = "shortcut",
		name = "FUE5Exporter__export-entities",
		action = "lua",
		icon = "__base__/graphics/icons/signal/signal_E.png",
		icon_size = 64,
		small_icon = "__base__/graphics/icons/signal/signal_E.png",
		small_icon_size = 64
	},
    {
        type = "selection-tool",
        name = "FUE5Exporter__export-selector",
        icon = "__base__/graphics/icons/signal/signal_E.png",
        icon_size = 64,
        subgroup = "tool",
        stack_size = 1,
        stackable = false,
        draw_label_for_cursor_render = true,
        
        -- New properties introduced in Factorio 2.0
        select = {
            border_color = { r = 0, g = 0, b = 1 },
            mode = "any-entity",
            cursor_box_type = "entity",
            entity_filter_mode = "blacklist",
            entity_type_filters = { "character", "resource", "spider-leg" }
        },
        alt_select = {
            border_color = { r = 1, g = 0, b = 0 },
            mode = "any-entity",
            cursor_box_type = "entity",
            entity_filter_mode = "blacklist",
            entity_type_filters = { "character", "resource", "spider-leg" }
        },
        
        -- Optional properties
        always_include_tiles = false,
        mouse_cursor = "selection-tool-cursor",
        skip_fog_of_war = false
    }
})

