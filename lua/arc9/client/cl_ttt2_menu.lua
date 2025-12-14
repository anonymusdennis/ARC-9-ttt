-- ARC9 TTT2 Configuration Menu
-- Client-side UI for configuring role-based permissions

if not CLIENT then return end

ARC9 = ARC9 or {}
ARC9.TTT2 = ARC9.TTT2 or {}

-- Create TTT2 configuration panel
local function CreateTTT2ConfigPanel(panel)
    if not ARC9.TTT2.Installed() then
        panel:ControlHelp("TTT2 is not installed. This menu requires TTT2 to function.")
        return
    end
    
    panel:AddControl("header", { description = "Configure role-based permissions for ARC9 weapons in TTT2." })
    panel:ControlHelp("Set which roles can customize weapons and access special features.")
    panel:ControlHelp("")
    
    -- Get all roles
    local roles = ARC9.TTT2.GetAllRoles()
    local currentPerms = ARC9.TTT2.GetRolePermissions()
    
    -- Default permissions section
    panel:AddControl("header", { description = "Default Permissions" })
    panel:ControlHelp("These permissions apply to roles not specifically configured below.")
    
    local defaultCustomize = currentPerms.default and currentPerms.default.customize or false
    local defaultInfiniteAmmo = currentPerms.default and currentPerms.default.infinite_ammo or false
    
    local defaultCustomizeCheck = panel:CheckBox("Default: Allow Customization", "arc9_ttt2_default_customize")
    local defaultInfiniteAmmoCheck = panel:CheckBox("Default: Infinite Ammo", "arc9_ttt2_default_infinite_ammo")
    
    panel:ControlHelp("")
    panel:AddControl("header", { description = "Role-Specific Permissions" })
    panel:ControlHelp("Configure permissions for each role individually.")
    panel:ControlHelp("")
    
    -- Create a scrollable panel for roles
    local roleList = vgui.Create("DListView", panel)
    roleList:SetSize(400, 300)
    roleList:SetMultiSelect(false)
    roleList:AddColumn("Role")
    roleList:AddColumn("Can Customize")
    roleList:AddColumn("Infinite Ammo")
    
    panel:AddItem(roleList)
    
    -- Populate role list
    local roleData = {}
    for _, role in ipairs(roles) do
        local roleName = role.name
        local perms = currentPerms[roleName] or { customize = false, infinite_ammo = false }
        
        local line = roleList:AddLine(
            roleName,
            perms.customize and "Yes" or "No",
            perms.infinite_ammo and "Yes" or "No"
        )
        
        line.roleName = roleName
        line.customize = perms.customize
        line.infinite_ammo = perms.infinite_ammo
        
        roleData[roleName] = line
    end
    
    panel:ControlHelp("")
    panel:ControlHelp("Double-click a role to edit its permissions.")
    
    -- Edit role permissions on double-click
    roleList.OnRowRightClick = function(self, lineID, line)
        local menu = DermaMenu()
        
        menu:AddOption("Toggle Customization", function()
            line.customize = not line.customize
            line:SetColumnText(2, line.customize and "Yes" or "No")
        end)
        
        menu:AddOption("Toggle Infinite Ammo", function()
            line.infinite_ammo = not line.infinite_ammo
            line:SetColumnText(3, line.infinite_ammo and "Yes" or "No")
        end)
        
        menu:Open()
    end
    
    roleList.DoDoubleClick = function(self, lineID, line)
        local roleName = line.roleName
        
        -- Create edit dialog
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 200)
        frame:SetTitle("Edit Permissions: " .. roleName)
        frame:Center()
        frame:MakePopup()
        
        local customizeCheck = vgui.Create("DCheckBoxLabel", frame)
        customizeCheck:SetPos(20, 40)
        customizeCheck:SetText("Allow Weapon Customization")
        customizeCheck:SetValue(line.customize)
        customizeCheck:SizeToContents()
        
        local infiniteAmmoCheck = vgui.Create("DCheckBoxLabel", frame)
        infiniteAmmoCheck:SetPos(20, 70)
        infiniteAmmoCheck:SetText("Infinite Ammo")
        infiniteAmmoCheck:SetValue(line.infinite_ammo)
        infiniteAmmoCheck:SizeToContents()
        
        local saveButton = vgui.Create("DButton", frame)
        saveButton:SetPos(20, 120)
        saveButton:SetSize(100, 30)
        saveButton:SetText("Save")
        saveButton.DoClick = function()
            line.customize = customizeCheck:GetChecked()
            line.infinite_ammo = infiniteAmmoCheck:GetChecked()
            line:SetColumnText(2, line.customize and "Yes" or "No")
            line:SetColumnText(3, line.infinite_ammo and "Yes" or "No")
            frame:Close()
        end
        
        local cancelButton = vgui.Create("DButton", frame)
        cancelButton:SetPos(140, 120)
        cancelButton:SetSize(100, 30)
        cancelButton:SetText("Cancel")
        cancelButton.DoClick = function()
            frame:Close()
        end
    end
    
    panel:ControlHelp("")
    
    -- Apply button
    local applyButton = vgui.Create("DButton", panel)
    applyButton:SetText("Apply Changes")
    applyButton:SetSize(200, 30)
    applyButton.DoClick = function()
        if not LocalPlayer():IsAdmin() then
            chat.AddText(Color(255, 100, 100), "[ARC9 TTT2] You must be an admin to change these settings!")
            return
        end
        
        -- Build permissions table
        local perms = {
            default = {
                customize = false, -- Will be read from actual ConVar if needed
                infinite_ammo = false
            }
        }
        
        for _, line in ipairs(roleList:GetLines()) do
            perms[line.roleName] = {
                customize = line.customize,
                infinite_ammo = line.infinite_ammo
            }
        end
        
        -- Encode and send to server
        local encoded = ARC9.TTT2.EncodeRolePermissions(perms)
        
        net.Start("arc9_ttt2_permissions_update")
        net.WriteString(encoded)
        net.SendToServer()
        
        chat.AddText(Color(100, 255, 100), "[ARC9 TTT2] Role permissions updated!")
    end
    
    panel:AddItem(applyButton)
    
    panel:ControlHelp("")
    panel:ControlHelp("Note: Changes require admin privileges and take effect immediately.")
end

-- Add to spawn menu
hook.Add("PopulateToolMenu", "ARC9_TTT2_MenuOptions", function()
    spawnmenu.AddToolMenuOption("Options", "ARC9", "ARC9_TTT2_Config", "TTT2 Integration", "", "", CreateTTT2ConfigPanel)
end)
