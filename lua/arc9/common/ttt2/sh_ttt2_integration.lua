-- ARC9 TTT2 Integration
-- Provides role-based weapon customization and configuration

ARC9 = ARC9 or {}
ARC9.TTT2 = ARC9.TTT2 or {}

-- Check if TTT2 is installed
ARC9.TTT2.Installed = function()
    return ROLES ~= nil
end

-- Default role permissions
-- These can be configured through the TTT2 configuration menu
ARC9.TTT2.DefaultRolePermissions = {
    -- Default permissions for any role not explicitly listed
    default = {
        customize = false,      -- Can customize weapons
        infinite_ammo = false,  -- Has infinite ammo
    }
}

-- Get role permissions from ConVar string
ARC9.TTT2.GetRolePermissions = function()
    local perms = {}
    
    if not ARC9.TTT2.Installed() then
        return perms
    end
    
    local convar = GetConVar("arc9_ttt2_role_permissions")
    if not convar then
        return ARC9.TTT2.DefaultRolePermissions
    end
    
    local convarStr = convar:GetString()
    
    if convarStr == "" then
        return ARC9.TTT2.DefaultRolePermissions
    end
    
    -- Parse the string format: "role:customize:infiniteammo|role2:customize:infiniteammo"
    local roleParts = string.Split(convarStr, "|")
    
    for _, rolePart in ipairs(roleParts) do
        local parts = string.Split(rolePart, ":")
        if #parts >= 3 then
            local roleName = parts[1]
            perms[roleName] = {
                customize = parts[2] == "1",
                infinite_ammo = parts[3] == "1",
            }
        end
    end
    
    -- Add default if not present
    if not perms.default then
        perms.default = ARC9.TTT2.DefaultRolePermissions.default
    end
    
    return perms
end

-- Check if a player can customize their weapon based on their role
ARC9.TTT2.CanCustomize = function(ply)
    if not IsValid(ply) then return false end
    if not ARC9.TTT2.Installed() then return true end -- If TTT2 not installed, allow customization
    
    -- Check global disable
    local nocustomize = GetConVar("arc9_atts_nocustomize")
    if nocustomize and nocustomize:GetBool() then
        return false
    end
    
    -- Check TTT2 role-based permissions
    local rolePerms = ARC9.TTT2.GetRolePermissions()
    
    -- Try to get the player's role
    local role = ply.GetSubRoleData and ply:GetSubRoleData() or nil
    
    if not role then
        -- Fallback to default permissions
        return rolePerms.default and rolePerms.default.customize or false
    end
    
    local roleName = role.name
    
    -- Check if this specific role has permissions set
    if rolePerms[roleName] then
        return rolePerms[roleName].customize
    end
    
    -- Check default permissions
    return rolePerms.default and rolePerms.default.customize or false
end

-- Check if a player has infinite ammo based on their role
ARC9.TTT2.HasInfiniteAmmo = function(ply)
    if not IsValid(ply) then return false end
    if not ARC9.TTT2.Installed() then return false end
    
    -- Check global infinite ammo
    local infiniteammo = GetConVar("arc9_infinite_ammo")
    if infiniteammo and infiniteammo:GetBool() then
        return true
    end
    
    -- Check TTT2 role-based permissions
    local rolePerms = ARC9.TTT2.GetRolePermissions()
    
    -- Try to get the player's role
    local role = ply.GetSubRoleData and ply:GetSubRoleData() or nil
    
    if not role then
        -- Check player-specific flag before default
        if ply.ARC9_TTT2_InfiniteAmmo then
            return true
        end
        return rolePerms.default and rolePerms.default.infinite_ammo or false
    end
    
    local roleName = role.name
    
    -- Check if this specific role has permissions set
    if rolePerms[roleName] then
        return rolePerms[roleName].infinite_ammo
    end
    
    -- Check player-specific infinite ammo flag (from traitor shop)
    if ply.ARC9_TTT2_InfiniteAmmo then
        return true
    end
    
    -- Check default permissions
    return rolePerms.default and rolePerms.default.infinite_ammo or false
end

-- Get all available roles
ARC9.TTT2.GetAllRoles = function()
    if not ARC9.TTT2.Installed() then return {} end
    
    local roles = {}
    
    for _, roleData in pairs(ROLES) do
        if roleData and roleData.name then
            table.insert(roles, {
                name = roleData.name,
                abbr = roleData.abbr or "",
                color = roleData.color or Color(255, 255, 255),
                defaultTeam = roleData.defaultTeam or "none"
            })
        end
    end
    
    -- Sort by name
    table.sort(roles, function(a, b) return a.name < b.name end)
    
    return roles
end

-- Encode role permissions to string format for ConVar storage
ARC9.TTT2.EncodeRolePermissions = function(perms)
    local parts = {}
    
    for roleName, rolePerms in pairs(perms) do
        if roleName ~= "default" then
            local customize = rolePerms.customize and "1" or "0"
            local infinite_ammo = rolePerms.infinite_ammo and "1" or "0"
            table.insert(parts, roleName .. ":" .. customize .. ":" .. infinite_ammo)
        end
    end
    
    return table.concat(parts, "|")
end

if SERVER then
    -- Create the ConVar for role permissions
    CreateConVar("arc9_ttt2_role_permissions", "", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Role-based permissions for ARC9 weapons in TTT2. Format: role:customize:infiniteammo|role2:customize:infiniteammo (e.g., traitor:1:0|detective:1:1)")
    
    -- Network string for syncing permissions
    util.AddNetworkString("arc9_ttt2_permissions_update")
    
    -- Network string for traitor shop purchases
    util.AddNetworkString("arc9_ttt2_shop_purchase")
    
    -- Handle permission updates from client
    net.Receive("arc9_ttt2_permissions_update", function(len, ply)
        if not IsValid(ply) or not ply:IsAdmin() then return end
        
        local permsStr = net.ReadString()
        GetConVar("arc9_ttt2_role_permissions"):SetString(permsStr)
        
        print("[ARC9 TTT2] " .. ply:GetName() .. " updated role permissions.")
    end)
    
    -- Initialize player-specific flags on spawn
    hook.Add("PlayerSpawn", "ARC9_TTT2_InitPlayer", function(ply)
        if not ply.ARC9_TTT2_InfiniteAmmo then
            ply.ARC9_TTT2_InfiniteAmmo = false
        end
    end)
    
    -- Reset player flags on round end
    hook.Add("TTTEndRound", "ARC9_TTT2_RoundEnd", function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                ply.ARC9_TTT2_InfiniteAmmo = false
            end
        end
    end)
    
    -- Reset player flags on round beginning
    hook.Add("TTTBeginRound", "ARC9_TTT2_RoundBegin", function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                ply.ARC9_TTT2_InfiniteAmmo = false
            end
        end
    end)
    
    -- Reset player flags on death
    hook.Add("PlayerDeath", "ARC9_TTT2_InfiniteAmmo_Death", function(victim, inflictor, attacker)
        if IsValid(victim) and victim.ARC9_TTT2_InfiniteAmmo then
            victim.ARC9_TTT2_InfiniteAmmo = false
        end
    end)
    
    print("[ARC9 TTT2] Integration loaded (Server)")
else
    -- Client-side only
    print("[ARC9 TTT2] Integration loaded (Client)")
end
