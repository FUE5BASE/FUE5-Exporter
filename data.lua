data:extend(
{
	{
		type = "shortcut",
		name = "FUE5Exporter__export-entities",
		action = "lua",
		icon = {
		filename = "__base__/graphics/icons/signal/signal_E.png",
		size = 64,
			scale = 1,
			flags = { "icon" }
		}
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
		selection_color = { r = 0, g = 0, b = 1 },
		alt_selection_color = { r = 1, g = 0, b = 0 },
		flags = { "only-in-cursor" },
		selection_mode = { "any-entity" },
		alt_selection_mode = { "any-entity" },
		selection_cursor_box_type = "entity",
		alt_selection_cursor_box_type = "entity",
		entity_filter_mode = "blacklist",
		entity_type_filters = {
			"character",
			"resource",
			"spider-leg"
		},
		alt_entity_filter_mode = "blacklist",
		alt_entity_type_filters = {
			"character",
			"resource",
			"spider-leg"
		}
	}
})

