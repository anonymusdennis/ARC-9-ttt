-- ARC9 TTT2 Traitor Shop Integration
-- Provides shop items for TTT2 roles

if not SERVER then return end

ARC9 = ARC9 or {}
ARC9.TTT2 = ARC9.TTT2 or {}

-- Only run if TTT2 is installed
hook.Add("Initialize", "ARC9_TTT2_CheckInstalled", function()
    if not ARC9.TTT2.Installed() then return end
    
    print("[ARC9 TTT2] Initializing shop integration...")
    
    -- Register equipment after TTT2 has fully loaded
    hook.Add("TTT2Initialize", "ARC9_TTT2_RegisterShopItems", function()
        -- Check if we have the required functions
        if not items or not items.Register then
            print("[ARC9 TTT2] Warning: items.Register not available")
            return
        end
        
        -- Register infinite ammo item
        local item = {
            id = "arc9_infinite_ammo",
            EquipMenuData = {
                type = "item_active",
                name = "Infinite Ammo (ARC9)",
                desc = "Grants infinite ammo for all ARC9 weapons for the rest of the round."
            },
            type = "item_active",
            material = "vgui/ttt/icon_ammo",
            CanBuy = { ROLE_TRAITOR, ROLE_DETECTIVE },
            limited = true,
            credits = 1,
        }
        
        -- Register with TTT2
        items.Register(item, "arc9_infinite_ammo")
        
        print("[ARC9 TTT2] Registered shop item: arc9_infinite_ammo")
    end)
    
    -- Hook for when item is bought
    hook.Add("TTT2FinishedLoading", "ARC9_TTT2_SetupBought", function()
        if not items or not items.GetStored then return end
        
        local item = items.GetStored("arc9_infinite_ammo")
        if not item then
            print("[ARC9 TTT2] Warning: Could not find registered item arc9_infinite_ammo")
            return
        end
        
        -- Override the Bought function
        item.Bought = function(self, buyer)
            if not IsValid(buyer) then return end
            
            -- Set the player's infinite ammo flag
            buyer.ARC9_TTT2_InfiniteAmmo = true
            
            -- Notify the player
            if LANG then
                LANG.Msg(buyer, "arc9_ttt2_infinite_ammo_bought", nil, MSG_MSTACK_PLAIN)
            else
                buyer:ChatPrint("You now have infinite ammo for ARC9 weapons!")
            end
            
            print("[ARC9 TTT2] " .. buyer:GetName() .. " purchased infinite ammo")
        end
    end)
    
    -- Add language strings for the shop item
    hook.Add("TTT2FinishedLoading", "ARC9_TTT2_AddLanguage", function()
        if LANG then
            LANG.AddToLanguage("english", "arc9_ttt2_infinite_ammo_bought", "You now have infinite ammo for ARC9 weapons!")
            LANG.AddToLanguage("english", "arc9_infinite_ammo_name", "Infinite Ammo (ARC9)")
            LANG.AddToLanguage("english", "arc9_infinite_ammo_desc", "Grants infinite ammo for all ARC9 weapons for the rest of the round.")
        end
    end)
end)

print("[ARC9 TTT2] Traitor shop integration file loaded")
