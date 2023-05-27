local pole_connection_offsets = {
	['small-electric-pole'] = {
		x = 0,
		y = 0,
		z = 4
	},
	['medium-electric-pole'] = {
		x = 0,
		y = 0,
		z = 4.875
	},
	['big-electric-pole'] = {
		x = -0.6,
		y = 0,
		z = 6
	},
	['substation'] = {
		x = 0,
		y = 0,
		z = 4.2
	}
}

function get_wire_connections(event)
	local connections = {}
	local exported_electic_poles = {}
	local visited_entities = {}

	for _, entity in ipairs(event.entities) do
		if entity.type == 'electric-pole' then
			exported_electic_poles[entity.unit_number] = true
		end
	end

	for _, entity in ipairs(event.entities) do
		if entity.type == 'electric-pole' then
			for _, neighbour in ipairs(entity.neighbours['copper']) do
				if exported_electic_poles[neighbour.unit_number] and visited_entities[neighbour.unit_number] == nil and pole_connection_offsets[entity.name] and pole_connection_offsets[neighbour.name] then
					table.insert(connections, {
						start = {
							x = entity.position.x + pole_connection_offsets[entity.name].x - event.area.left_top.x,
							y = entity.position.y + pole_connection_offsets[entity.name].y - event.area.left_top.y,
							z = pole_connection_offsets[entity.name].z
						},
						target = {
							x = neighbour.position.x + pole_connection_offsets[neighbour.name].x - event.area.left_top.x,
							y = neighbour.position.y + pole_connection_offsets[neighbour.name].y - event.area.left_top.y,
							z = pole_connection_offsets[neighbour.name].z
						}
					})
				end
			end
			visited_entities[entity.unit_number] = true
		end
	end

	return connections
end

return {
	get_wire_connections = get_wire_connections
}
