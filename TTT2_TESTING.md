# TTT2 Integration Testing Guide

This guide explains how to test the ARC9 TTT2 integration features.

## Prerequisites

1. **Garry's Mod** with a dedicated server or listen server
2. **TTT2** installed and working
3. **ARC9 Base** with TTT2 integration
4. **At least one ARC9 weapon pack** (for testing)
5. **Admin privileges** on the server

## Test Environment Setup

### Option 1: Listen Server (Quickest)
1. Start Garry's Mod
2. Create a new game with gamemode "TTT2"
3. Set map to any TTT map (e.g., `ttt_minecraft_b5`)
4. Enable "Enable Developer Console"
5. Start the game

### Option 2: Dedicated Server
1. Set up a dedicated server with TTT2
2. Configure `server.cfg` with your admin credentials
3. Add yourself as superadmin in `data/ULib/users.txt` or through ULX
4. Connect to your server

## Test Cases

### 1. Configuration Menu Access

**Test**: Verify the configuration menu is accessible
1. Press `ESC` to open the menu
2. Navigate to `Options` → `ARC9` → `TTT2 Integration`
3. **Expected**: Menu opens showing role permissions table

**Note**: If TTT2 is not installed, you should see a message stating "TTT2 is not installed"

### 2. Role-Based Customization Restrictions

#### Test 2.1: Innocent Role (Default: Cannot Customize)
1. Start a TTT round: `ttt_roundrestart` in console
2. Ensure you are assigned the Innocent role
3. Pick up an ARC9 weapon
4. Press `C` (default customize key)
5. **Expected**: Notification appears: "Your role cannot customize weapons!"
6. **Expected**: Customization menu does NOT open

#### Test 2.2: Configure Role to Allow Customization
1. Open the TTT2 Integration menu (as admin)
2. Double-click on "innocent" role in the list
3. Check "Allow Weapon Customization"
4. Click "Save"
5. Click "Apply Changes" in the main menu
6. Start a new round: `ttt_roundrestart`
7. As Innocent, press `C` on an ARC9 weapon
8. **Expected**: Customization menu opens successfully

#### Test 2.3: Traitor Role
1. In the TTT2 Integration menu, ensure "traitor" has customization enabled
2. Click "Apply Changes"
3. Force yourself to be traitor: `ttt_force_traitor` in console
4. Start a round: `ttt_roundrestart`
5. Pick up an ARC9 weapon
6. Press `C`
7. **Expected**: Customization menu opens

### 3. Infinite Ammo System

#### Test 3.1: Role-Based Infinite Ammo
1. Open TTT2 Integration menu
2. Double-click "detective" role
3. Check "Infinite Ammo"
4. Click "Save" and "Apply Changes"
5. Force detective role: `ttt_force_detective` in console
6. Start a round: `ttt_roundrestart`
7. Pick up an ARC9 weapon
8. Fire multiple times
9. **Expected**: Ammo counter does not decrease
10. **Expected**: Reserve ammo stays full

#### Test 3.2: Shop Item Purchase
1. Configure a role without infinite ammo (e.g., traitor)
2. Force traitor role: `ttt_force_traitor`
3. Start a round: `ttt_roundrestart`
4. Give yourself credits: `ttt_credits_add [yourname] 10`
5. Press `C` to open traitor shop
6. Look for "Infinite Ammo (ARC9)" item
7. Purchase the item (should cost 1 credit)
8. **Expected**: Receive notification "You now have infinite ammo for ARC9 weapons!"
9. Pick up an ARC9 weapon and fire
10. **Expected**: Ammo counter does not decrease

#### Test 3.3: Infinite Ammo Reset on Death
1. Purchase infinite ammo from shop
2. Verify ammo doesn't decrease
3. Kill yourself: `kill` in console
4. Respawn
5. Pick up an ARC9 weapon
6. **Expected**: Ammo counter decreases normally (infinite ammo removed)

#### Test 3.4: Infinite Ammo Reset on Round End
1. Purchase infinite ammo from shop
2. End the round: `ttt_roundrestart`
3. Pick up an ARC9 weapon
4. **Expected**: Ammo counter decreases normally (infinite ammo removed)

### 4. Multi-Role Testing

#### Test 4.1: Custom Roles
If you have custom TTT2 roles installed (e.g., Vampire, Jackal):
1. Open TTT2 Integration menu
2. **Expected**: All custom roles appear in the list
3. Configure permissions for a custom role
4. Force that role: `ttt_force_[rolename]`
5. Start a round
6. Test customization and infinite ammo based on configuration
7. **Expected**: Permissions work as configured

### 5. Permission Persistence

#### Test 5.1: Server Restart
1. Configure role permissions
2. Click "Apply Changes"
3. Restart the server
4. Check TTT2 Integration menu
5. **Expected**: Previous configuration is retained

#### Test 5.2: ConVar Verification
1. Configure permissions
2. Run in console: `arc9_ttt2_role_permissions`
3. **Expected**: Output shows encoded permissions string
4. Example: `traitor:1:0|detective:1:1|innocent:0:0`

### 6. Admin-Only Restrictions

#### Test 6.1: Non-Admin Cannot Change Settings
1. Remove your admin privileges temporarily
2. Open TTT2 Integration menu
3. Change role permissions
4. Click "Apply Changes"
5. **Expected**: Error message in chat: "You must be an admin to change these settings!"
6. Check ConVar: `arc9_ttt2_role_permissions`
7. **Expected**: Configuration unchanged

### 7. Compatibility Testing

#### Test 7.1: Global Settings Override
1. Set `arc9_atts_nocustomize 1` in console
2. Configure a role to allow customization
3. Start a round with that role
4. Press `C` on an ARC9 weapon
5. **Expected**: Customization is blocked (global setting takes priority)

#### Test 7.2: Non-TTT2 Mode
1. Switch to a non-TTT gamemode (e.g., Sandbox)
2. Pick up an ARC9 weapon
3. Press `C`
4. **Expected**: Customization works normally (TTT2 restrictions don't apply)

## Console Commands for Testing

```
// Role forcing
ttt_force_traitor
ttt_force_detective
ttt_force_innocent

// Round control
ttt_roundrestart

// Credit manipulation
ttt_credits_add [yourname] [amount]

// Check permissions
arc9_ttt2_role_permissions

// Global customization toggle
arc9_atts_nocustomize [0/1]

// Global infinite ammo
arc9_infinite_ammo [0/1]
```

## Expected Console Output

When the integration loads correctly, you should see:
```
[ARC9 TTT2] Integration loaded (Server)
[ARC9 TTT2] Integration loaded (Client)
[ARC9 TTT2] Initializing shop integration...
[ARC9 TTT2] Registered shop item: arc9_infinite_ammo
[ARC9 TTT2] Traitor shop integration file loaded
```

## Troubleshooting

### Configuration menu is empty
- Verify TTT2 is installed: Check for `ROLES` global in console
- Check console for errors

### Shop item not appearing
- Verify TTT2 shop system is working with other items
- Check console for "[ARC9 TTT2]" messages
- Try: `lua_run PrintTable(items.GetList())`

### Permissions not saving
- Verify you have admin privileges
- Check file permissions in `garrysmod/cfg/`
- Look for errors in server console

### Customization blocked unexpectedly
- Check `arc9_atts_nocustomize` is 0
- Verify role permissions in menu
- Check console output when pressing C

## Reporting Issues

When reporting issues, please include:
1. Server/client console output
2. Value of `arc9_ttt2_role_permissions`
3. List of installed addons
4. Steps to reproduce
5. Screenshots if applicable

## Performance Testing

Monitor performance with:
```
net_graph 3  // Show network stats
r_speeds 1   // Show render stats
```

The integration should have minimal performance impact as it only:
- Checks permissions when customization is requested
- Checks infinite ammo during reload operations
- Adds one shop item registration

## Success Criteria

All tests pass if:
- ✅ Configuration menu accessible to admins
- ✅ Role-based customization restrictions work
- ✅ Role-based infinite ammo works
- ✅ Shop item can be purchased and functions
- ✅ Infinite ammo resets on death/round end
- ✅ Custom roles are supported
- ✅ Permissions persist across restarts
- ✅ Non-admins cannot change settings
- ✅ No console errors during normal operation
