function any_to_straight(from_rail, to_rail)
	local diff = {
		x = to_rail.x - from_rail.x,
		y = to_rail.y - from_rail.y
	}

	if diff.x < 0 and math.abs(diff.x) > math.abs(diff.y) then
		return true
	elseif diff.y > 0 and math.abs(diff.y) > math.abs(diff.x) then
		return true
	else
		return false
	end
end

function always_normal()
	return false
end

function inverted_previous(from_rail, to_rail, from_inverted)
	return not from_inverted
end

function copy_previous(from_rail, to_rail, from_inverted)
	return from_inverted
end

local rail_transitions = {
	["straight-rail-I"] = {
		["straight-rail-I"] = any_to_straight,
		["curved-rail-R"] = always_normal,
		["curved-rail-L"] = always_normal
	},
	["curved-rail-R"] = {
		["straight-rail-I"] = any_to_straight,
		["curved-rail-R"] = inverted_previous,
		["curved-rail-L"] = inverted_previous,
		["straight-rail-/"] = inverted_previous
	},
	["curved-rail-L"] = {
		["straight-rail-I"] = any_to_straight,
		["curved-rail-R"] = inverted_previous,
		["curved-rail-L"] = inverted_previous,
		["straight-rail-/"] = copy_previous
	},
	["straight-rail-/"] = {
		["curved-rail-R"] = inverted_previous,
		["curved-rail-L"] = copy_previous,
		["straight-rail-/"] = inverted_previous
	}
}

function get_first_rail_variant(exported_entities, path)
	local from_rail = exported_entities[path[2].index + 1]
	local to_rail = exported_entities[path[1].index + 1]
	local variant = rail_transitions[from_rail.name .. '-' .. from_rail.variant][to_rail.name .. '-' .. to_rail.variant](
	from_rail, to_rail, path[2].invert_spline)
	if from_rail.name == 'straight-rail' and from_rail.variant == 'I' or to_rail.name == 'straight-rail' and to_rail.variant == 'I' then
		return not variant
	end
	return variant
end

function get_train_paths(event, exported_entities, exported_entities_map, print)
	local exported_rails = {}
	local exported_trains = {}
	for _, entity in ipairs(event.entities) do
		if entity.type == 'straight-rail' or entity.type == 'curved-rail' then
			exported_rails[entity.unit_number] = true
		elseif entity.type == 'locomotive' and entity.train.has_path then
			exported_trains[entity.train.id] = entity.train
		end
	end

	local train_paths = {}
	for _, train in pairs(exported_trains) do
		-- find train path segment inside exported area
		local first = 0
		local last = 0
		for i, path_rail in pairs(train.path.rails) do
			if first == 0 then
				if exported_rails[path_rail.unit_number] then
					first = i
				end
			else
				last = i - 1
				if not exported_rails[path_rail.unit_number] then
					break
				end
			end
		end

		if first ~= last then
			local path = {}
			for i = first, last do
				table.insert(path, {
					index = exported_entities_map[train.path.rails[i].unit_number] - 1
				})
			end

			for i = 2, table_size(path) do
				local from_rail = exported_entities[path[i - 1].index + 1]
				local to_rail = exported_entities[path[i].index + 1]

				path[i].invert_spline = rail_transitions[from_rail.name .. '-' .. from_rail.variant]
				[to_rail.name .. '-' .. to_rail.variant](from_rail, to_rail, path[i - 1].invert_spline)
			end
			path[1].invert_spline = get_first_rail_variant(exported_entities, path)

			local back_movers = {}
			for _, locomotive in ipairs(train.locomotives.back_movers) do
				back_movers[locomotive.unit_number] = true
			end

			local carriages = {}
			for _, carriage in ipairs(train.carriages) do
				table.insert(carriages, {
					name = carriage.name,
					back_mover = back_movers[carriage.unit_number] or false
				})
			end

			table.insert(train_paths, {
				carriages = carriages,
				path = path
			})
		end
	end

	return train_paths
end

return {
	get_train_paths = get_train_paths
}
