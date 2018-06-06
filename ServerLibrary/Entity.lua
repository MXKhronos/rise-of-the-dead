return {
    SpawnEntity = function(entityType, entityName)
        local modType = script:FindFirstChild(entityType);
        if modType then
            entityType = require(modType);
            return entityType.Spawn(entityName);
        else
            error("Entity type: "..entityType.." does not exist.");
        end
    end;
};