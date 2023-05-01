function add_entities(chests, chest_indexes, exported_entities_map)
    for _, chest in ipairs(chests) do
        if exported_entities_map[chest.unit_number] then
            chest_indexes[exported_entities_map[chest.unit_number] - 1] = true
        end
    end
end

function get_logistic_systems(event, exported_entities, exported_entities_map, print)
    local systems = {}
    local player = game.players[event.player_index]
    for i, logistic_network in ipairs(player.force.logistic_networks[player.surface.name]) do
        local roboport_indexes = {}
        for _, cell in ipairs(logistic_network.cells) do
            if exported_entities_map[cell.owner.unit_number] then
                print(cell.owner.unit_number)
                table.insert(roboport_indexes, exported_entities_map[cell.owner.unit_number] - 1)
            end
        end

        local chest_indexes = {}
        add_entities(logistic_network.providers, chest_indexes, exported_entities_map)
        add_entities(logistic_network.empty_providers, chest_indexes, exported_entities_map)
        add_entities(logistic_network.requesters, chest_indexes, exported_entities_map)
        add_entities(logistic_network.storages, chest_indexes, exported_entities_map)

        for _, index in pairs(roboport_indexes) do
            chest_indexes[index] = nil
        end

        print(i .. ' ' .. #roboport_indexes .. ' ' .. #logistic_network.cells)
        if #roboport_indexes > 0 and next(chest_indexes) then
            local indexes = {}
            for index, _ in pairs(chest_indexes) do
                table.insert(indexes, index)
            end

            table.insert(systems, {
                roboports = roboport_indexes,
                chests = indexes
            })
        end
    end
    return systems
end

return {
    get_logistic_systems = get_logistic_systems
}
