local export_entities = require('scripts.export_entities').export_entities
local get_bounds = require('scripts.bounds').get_bounds
local get_wire_connections = require('scripts.wire_connections').get_wire_connections
local get_train_paths = require('scripts.train_paths').get_train_paths
local get_belt_paths = require('scripts.belt_paths').get_belt_paths
local get_logistic_systems = require('scripts.logistic_systems').get_logistic_systems
local serialize = require('scripts.serialize').serialize
local export_schema = require('export_schema')

function get_min_point(entities)
	min_x = nil
	min_y = nil
	for _, entity in ipairs(entities) do
		if min_x == nil or min_x > entity.position.x then
			min_x = entity.position.x
		end
		if min_y == nil or min_y > entity.position.y then
			min_y = entity.position.y
		end
	end

	return {
		x = min_x,
		y = min_y
	}
end

function process(event, debug, print)
	if event.item and event.item == 'FUE5Exporter__export-selector' then
		event.area.left_top = get_min_point(event.entities)

		print('Exported entities')
		local exported_entities, exported_entities_map = export_entities(event, print)

		print('Bounds')
		local bounds = get_bounds(exported_entities)

		-- print('Wire connection')
		-- local wire_connections = get_wire_connections(event)
		-- Removed wire connections for now, as it causes problems, that I have no idea how to fix lol

		print('Train paths')
		local train_paths = get_train_paths(event, exported_entities, exported_entities_map, print)

		print('Belt paths')
		local belt_paths = get_belt_paths(event, exported_entities, exported_entities_map, print)

		print('Logistic systems')
		local logistic_systems = get_logistic_systems(event, exported_entities, exported_entities_map, print)

		if not debug then
			helpers.write_file('exported-entities.json',
				serialize(export_schema, {
					entities = exported_entities,
					bounds = bounds,
					wire_connections = wire_connections,
					train_paths = train_paths,
					belt_paths = belt_paths,
					logistic_systems = logistic_systems
				}),
				false,
				event.player_index)

			game.players[event.player_index].print('Export done')
		end
	end
end

function do_nothing(value)
end

function on_player_selected_area(event)
	process(event, false, do_nothing)
end

function on_player_alt_selected_area(event)
	local player = game.players[event.player_index]
	process(event, true, player.print)
end

function on_lua_shortcut(event)
	if event.prototype_name == 'FUE5Exporter__export-entities' then
		local player = game.players[event.player_index]
		if player.clear_cursor() then
			local stack = player.cursor_stack
			if player.cursor_stack and stack.can_set_stack({ name = 'FUE5Exporter__export-selector' }) then
				stack.set_stack({ name = 'FUE5Exporter__export-selector' })
			end
		end
	end
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)
script.on_event(defines.events.on_lua_shortcut, on_lua_shortcut)
