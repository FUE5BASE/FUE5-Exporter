function entity_direction_to_number(entity_direction)
	local directions = defines.direction
	if entity_direction == directions.northwest then
		return 7
	elseif entity_direction == directions.west then
		return 6
	elseif entity_direction == directions.southwest then
		return 5
	elseif entity_direction == directions.south then
		return 4
	elseif entity_direction == directions.southeast then
		return 3
	elseif entity_direction == directions.east then
		return 2
	elseif entity_direction == directions.northeast then
		return 1
	else
		return 0
	end
end

function entity_size(entity)
	return entity.selection_box.right_bottom.x - entity.selection_box.left_top.x,
		entity.selection_box.right_bottom.y - entity.selection_box.left_top.y
end

function entity_prototype_size(entity)
	return entity_size(entity.prototype)
end

function neighbour_direction(source, neighbour)
	local neighbour_width, neighbour_height = entity_size(neighbour)

	if neighbour.position.y + neighbour_height / 2 < source.position.y then
		return 0
	elseif neighbour.position.x - neighbour_width / 2 > source.position.x then
		return 2
	elseif neighbour.position.y - neighbour_height / 2 > source.position.y then
		return 4
	elseif neighbour.position.x + neighbour_width / 2 < source.position.x then
		return 6
	end
end

function get_neighbour_directions(entity, neighbours)
	local directions = {}
	for _, neighbour in pairs(neighbours) do
		local direction = neighbour_direction(entity, neighbour)
		directions[direction] = true
		directions[direction + 8] = true
	end

	return directions
end

function get_pipe_type(directions)
	local count = table_size(directions)
	if count <= 2 then
		return 'I', next(directions) or 0
	elseif count == 4 then
		for i = 0, 2, 2 do
			if directions[i] and directions[i + 4] then
				return 'I', i
			end
		end
		for i = 0, 6, 2 do
			if directions[i] and directions[i + 2] then
				return 'L', i
			end
		end
	elseif count == 6 then
		for i = 0, 6, 2 do
			if not directions[i] then
				return 'T', i
			end
		end
	else
		return 'X', 0
	end
end

function export_entities(event, print)
	local exported_entities = {}
	local exported_entities_map = {}

	for _, entity in ipairs(event.entities) do
		local width, height = entity_prototype_size(entity)
		local export = {
			name = entity.name,
			x = entity.position.x - event.area.left_top.x,
			y = entity.position.y - event.area.left_top.y,
			direction = entity_direction_to_number(entity.direction),
			width = width,
			height = height
		}

		if entity.type == 'pipe' then
			local name_suffix, direction = get_pipe_type(get_neighbour_directions(entity, entity.neighbours[1]))
			export.variant = name_suffix
			export.direction = direction
		end

		if entity.type == 'arithmetic-combinator' then
			export.operation = entity.get_control_behavior().parameters.operation
		end

		if entity.type == 'decider-combinator' then
			export.operation = entity.get_control_behavior().parameters.comparator
		end

		if entity.type == 'transport-belt' then
			local neighbour_directions = get_neighbour_directions(entity, entity.belt_neighbours.inputs)
			local has_right = neighbour_directions[export.direction + 2]
			local has_bottom = neighbour_directions[export.direction + 4]
			local has_left = neighbour_directions[export.direction + 6]

			if (has_right == has_left) or has_bottom then
				export.variant = 'I'
			elseif has_right then
				export.variant = 'R'
			else
				export.variant = 'L'
			end
		end

		if entity.type == 'underground-belt' and entity.belt_to_ground_type == 'input' then
			export.direction = (export.direction + 4) % 8
		end

		if export.name == 'straight-rail' then
			if export.direction % 2 == 1 then
				export.variant = '/'
				export.x = export.x + 0.5 - math.floor(export.direction / 4)
				export.y = export.y - 0.5 + math.floor(((export.direction + 2) % 8) / 4)
				export.direction = math.floor(export.direction / 2) * 2
			else
				export.variant = 'I'
			end
		end

		if export.name == 'curved-rail' then
			if export.direction % 2 == 1 then
				export.variant = 'R'
				export.direction = math.floor(export.direction / 2) * 2
			else
				export.variant = 'L'
				export.direction = math.floor(export.direction / 2) * 2
			end
		end

		if entity.type == 'tree' then
			export.name = 'tree'
		end

		print(entity.type .. ' ' .. export.name .. ' ' .. export.direction)

		table.insert(exported_entities, export)
		if entity.unit_number ~= nil then
			exported_entities_map[entity.unit_number] = #exported_entities
		end
	end

	return exported_entities, exported_entities_map
end

return {
	export_entities = export_entities
}
