function get_belt_paths(event, exported_entities, exported_entities_map, print)
    local belts = {}
    local exported_belt_map = {}
    for _, entity in ipairs(event.entities) do
        if entity.type == 'transport-belt' then
            table.insert(belts, entity)
            exported_belt_map[entity.unit_number] = exported_entities_map[entity.unit_number]
        end
    end

    local forward_graph = {}
    local backwards_graph = {}
    local visited_belts = {}
    local belt_segments = {}
    for _, b in ipairs(belts) do
        local belts_to_visit = { b }

        local belt_segment = {}
        for _, belt in ipairs(belts_to_visit) do
            if not visited_belts[belt.unit_number] then
                local exported_belt = exported_entities[exported_belt_map[belt.unit_number]]
                table.insert(belt_segment, belt)
                visited_belts[belt.unit_number] = true

                for _, input_belt in ipairs(belt.belt_neighbours['inputs']) do
                    if exported_belt_map[input_belt.unit_number] then
                        if exported_belt.variant ~= 'I' or belt.direction == input_belt.direction then
                            table.insert(belts_to_visit, input_belt)
                            forward_graph[input_belt.unit_number] = belt
                            backwards_graph[belt.unit_number] = input_belt
                        end
                    end
                end
                for _, output_belt in ipairs(belt.belt_neighbours['outputs']) do
                    local index = exported_belt_map[output_belt.unit_number]
                    if index then
                        local exported_output_belt = exported_entities[index]
                        if exported_output_belt.variant ~= 'I' or belt.direction == output_belt.direction then
                            table.insert(belts_to_visit, output_belt)
                            forward_graph[belt.unit_number] = output_belt
                            backwards_graph[output_belt.unit_number] = belt
                        end
                    end
                end
            end
        end

        if #belt_segment > 0 then
            table.insert(belt_segments, belt_segment)
        end
    end

    local belt_paths = {}
    for _, belt_segment in ipairs(belt_segments) do
        visited_belts = {}
        local belt = belt_segment[1]
        local start_belt = belt
        repeat
            start_belt = belt
            belt = backwards_graph[belt.unit_number]
        until not belt or belt == belt_segment[1]

        belt = start_belt
        local belt_indexes = {}
        local belt_items_1 = {}
        local belt_items_2 = {}
        repeat
            table.insert(belt_indexes, exported_belt_map[belt.unit_number] - 1)
            for item, _ in pairs(belt.get_transport_line(1).get_contents()) do
                belt_items_1[item] = true
            end
            for item, _ in pairs(belt.get_transport_line(2).get_contents()) do
                belt_items_2[item] = true
            end
            belt = forward_graph[belt.unit_number]
        until not belt or belt == start_belt

        local items_1 = {}
        for item, _ in pairs(belt_items_1) do
            table.insert(items_1, item)
        end

        local items_2 = {}
        for item, _ in pairs(belt_items_2) do
            table.insert(items_2, item)
        end

        table.insert(belt_paths, {
            path = belt_indexes,
            items_lane_l = items_1,
            items_lane_r = items_2,
        })
    end

    return belt_paths
end

return {
    get_belt_paths = get_belt_paths
}
