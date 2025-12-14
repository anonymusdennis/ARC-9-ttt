-- ARC9 TTT2 Traitor Shop Integration
-- Provides shop items for TTT2 roles

if not SERVER then return end

ARC9 = ARC9 or {}
ARC9.TTT2 = ARC9.TTT2 or {}

-- Only run if TTT2 is installed
if not ARC9.TTT2.Installed() then return end

-- Infinite Ammo Shop Item
if ITEM then
    -- Define the infinite ammo equipment item
    local infiniteAmmoItem = {
        id = "arc9_infinite_ammo",
        EquipMenuData = {
            type = "item_active",
            name = "Infinite Ammo (ARC9)",
            desc = "Grants infinite ammo for all ARC9 weapons for the rest of the round."
        },
        type = "item_active",
        material = "vgui/ttt/icon_ammo",
        CanBuy = { ROLE_TRAITOR },
        limited = true,
        -- Price in credits
        credits = 1,
    }
    
    -- Register the item with TTT2
    ITEM.EquipMenuData = infiniteAmmoItem.EquipMenuData
    ITEM.type = infiniteAmmoItem.type
    ITEM.material = infiniteAmmoItem.material
    ITEM.CanBuy = infiniteAmmoItem.CanBuy
    ITEM.limited = infiniteAmmoItem.limited
    
    -- Called when the item is bought
    function ITEM:Bought(buyer)
        if not IsValid(buyer) then return end
        
        -- Set the player's infinite ammo flag
        buyer.ARC9_TTT2_InfiniteAmmo = true
        
        -- Notify the player
        LANG.Msg(buyer, "arc9_ttt2_infinite_ammo_bought", nil, MSG_MSTACK_PLAIN)
    end
    
    -- Reset on death
    hook.Add("PlayerDeath", "ARC9_TTT2_InfiniteAmmo_Death", function(victim, inflictor, attacker)
        if IsValid(victim) and victim.ARC9_TTT2_InfiniteAmmo then
            victim.ARC9_TTT2_InfiniteAmmo = false
        end
    end)
else
    -- Alternative registration method if ITEM is not available yet
    hook.Add("TTT2Initialize", "ARC9_TTT2_RegisterShopItems", function()
        -- Create infinite ammo item
        local item = {
            id = "arc9_infinite_ammo",
            EquipMenuData = {
                type = "item_active",
                name = "Infinite Ammo (ARC9)",
                desc = "Grants infinite ammo for all ARC9 weapons for the rest of the round."
            },
            type = "item_active",
            material = "vgui/ttt/icon_ammo",
            CanBuy = { ROLE_TRAITOR },
            limited = true,
            credits = 1,
            
            Bought = function(self, buyer)
                if not IsValid(buyer) then return end
                buyer.ARC9_TTT2_InfiniteAmmo = true
            end
        }
        
        -- Try to register with TTT2's shop system
        if items and items.Register then
            items.Register(item, "arc9_infinite_ammo")
        end
    end)
end

-- Add language strings for the shop item
hook.Add("Initialize", "ARC9_TTT2_AddLanguage", function()
    -- Try to add language strings
    if LANG then
        LANG.AddToLanguage("english", "arc9_ttt2_infinite_ammo_bought", "You now have infinite ammo for ARC9 weapons!")
        LANG.AddToLanguage("english", "arc9_infinite_ammo_name", "Infinite Ammo (ARC9)")
        LANG.AddToLanguage("english", "arc9_infinite_ammo_desc", "Grants infinite ammo for all ARC9 weapons for the rest of the round.")
    end
end)

-- Hook into ammo giving to provide infinite ammo
hook.Add("EntityTakeDamage", "ARC9_TTT2_InfiniteAmmoCheck", function(target, dmginfo)
    -- This is just a placeholder hook for infinite ammo checks
    -- The actual infinite ammo logic is handled in the weapon code
end)

print("[ARC9 TTT2] Traitor shop integration loaded")
