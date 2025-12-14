# ARC9 TTT2 Integration

This integration adds role-based weapon customization and features for Trouble in Terrorist Town 2 (TTT2).

## Features

### Role-Based Weapon Customization
- Configure which roles can customize their ARC9 weapons
- Prevents unauthorized players from accessing the customization menu
- Works with all TTT2 roles (Innocent, Traitor, Detective, and custom roles)

### Role-Based Infinite Ammo
- Configure which roles have infinite ammo by default
- Per-role configuration through the admin menu

### Traitor Shop Integration
- **Infinite Ammo** - Purchase item from traitor/detective shop for 1 credit
- Grants infinite ammo for all ARC9 weapons for the rest of the round
- Resets on death and round end

## Configuration

### Admin Menu
Access the configuration menu through: **ESC → Options → ARC9 → TTT2 Integration**

The menu allows you to:
1. Set default permissions for roles not specifically configured
2. Configure individual role permissions:
   - **Can Customize**: Whether the role can customize weapons
   - **Infinite Ammo**: Whether the role has infinite ammo by default

### ConVars
- `arc9_ttt2_role_permissions` - Stores role-based permissions (automatically managed by the UI)
  - Format: `role:customize:infiniteammo|role2:customize:infiniteammo`
  - Example: `innocent:0:0|traitor:1:0|detective:1:1`

### Example Configuration

**Default Settings (Recommended for TTT2):**
- **Innocent**: Cannot customize, no infinite ammo
- **Traitor**: Can customize, no infinite ammo (can buy from shop)
- **Detective**: Can customize, no infinite ammo (can buy from shop)

**Custom Role Support:**
All custom roles from TTT2 addons are automatically detected and can be configured through the menu.

## Usage

### For Server Admins
1. Install ARC9 base and this integration
2. Install TTT2
3. Access the configuration menu (requires admin)
4. Set permissions for each role
5. Click "Apply Changes"

### For Players
- Players with customization permission can press the customize key (default: C) to access the menu
- Players without permission will see a notification when trying to customize
- Traitors and Detectives can purchase infinite ammo from their shop for 1 credit

## Compatibility

- **Requires**: TTT2 (Trouble in Terrorist Town 2)
- **Compatible with**: All TTT2 custom roles
- **Works with**: Existing ARC9 weapon packs

## Troubleshooting

### Customization menu not opening
- Check if your role has permission in the admin menu
- Verify `arc9_atts_nocustomize` is set to 0

### Shop item not appearing
- Verify TTT2 is properly installed
- Check server console for "[ARC9 TTT2]" messages
- Restart the server after installation

### Role permissions not saving
- Ensure you have admin privileges
- Check that the server is not read-only
- Verify the ConVar is replicated properly

## Technical Details

### File Structure
```
lua/
├── arc9/
│   ├── client/
│   │   └── cl_ttt2_menu.lua          # Configuration UI
│   ├── common/
│   │   └── ttt2/
│   │       └── sh_ttt2_integration.lua  # Core integration
│   └── server/
│       └── sv_ttt2_shop.lua          # Shop items
```

### Hooks
- `TTT2Initialize` - Registers shop items
- `TTT2FinishedLoading` - Finalizes shop item setup
- `TTTBeginRound` - Resets infinite ammo flags
- `PlayerSpawn` - Initializes player flags
- `PlayerDeath` - Resets player flags on death

## Extending

### Adding Custom Shop Items

You can add your own shop items by following this pattern:

```lua
hook.Add("TTT2Initialize", "YourMod_RegisterShopItems", function()
    if not items or not items.Register then return end
    
    local item = {
        id = "your_item_id",
        EquipMenuData = {
            type = "item_active",
            name = "Your Item Name",
            desc = "Your item description"
        },
        type = "item_active",
        material = "vgui/ttt/your_icon",
        CanBuy = { ROLE_TRAITOR },
        limited = true,
        credits = 1,
    }
    
    items.Register(item, "your_item_id")
end)
```

### Adding Custom Permissions

To add additional permission types, modify the `ARC9.TTT2.DefaultRolePermissions` table in `sh_ttt2_integration.lua`.

## Credits

- ARC9 Base by Arctic
- TTT2 by TTT2 Team
- Integration by [contributors]
