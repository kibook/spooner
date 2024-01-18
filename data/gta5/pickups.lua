Pickups = {
}

PickupsHashLookup = {}
for _, name in ipairs(Pickups) do PickupsHashLookup[GetHashKey(name)] = name; end
