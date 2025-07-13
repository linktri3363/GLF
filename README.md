# GLF - FFXI Limbus NM Detector

**Author:** Linktri  
**Version:** 1.0  

*******WARNING******* THIS ADDON SENDS A CHECK COMMAND FOR EACH MOB IN RANGE EVEN THOUGH YOU CANNOT SEE IT OCURRING. AS A SAFETY PRECAUTION EACH CHECK ACTION IS SET TO OCCUR 1.5 SECONDS FROM THE LAST. 
*******WARNING******* AUTO CHECK IS SET TO 20 SECONDS. THIS MEANS THAT YOU IF YOU ARE IN RANGE OF 80 MOBS, IT WILL TAKE 2 MINS TO COMPLETE DETECTION. YOU CAN CHANGE THE FREQUENCY OF AUTO SCAN AND MANUALLY TRIGGER SCANS. 
*******WARNING******* YOU CAN OVERLOAD THE FFXI SERVER IF YOU MODIFY THESE SETTINGS, WHICH WILL LIKELY RESULT IN A PERMANENT BAN. 


GLF is a Windower addon for Final Fantasy XI that automatically detects "impossible to gauge" notorious monsters in Limbus zones (Apollyon and Temenos). This addon is specifically designed for the 2025 Limbus content update where notorious monsters spawn with unknown conditions and can only be identified by their difficulty rating.

## Features

- **Automatic Detection**: Continuously scans for "impossible to gauge" monsters every 20 seconds
- **Manual Scanning**: On-demand scanning with instant results
- **Zone Filtering**: Only operates in Limbus zones (configurable)
- **Visual Alerts**: Clear chat notifications when NMs are detected
- **Audio Alerts**: Optional sound notifications (if sound file is available)
- **Auto-Targeting**: Automatically targets detected NMs
- **Zone Management**: Tools to identify and add new zone IDs
- **Configurable Settings**: Adjustable scan intervals and toggleable features

## Installation

1. Download `glf.lua` and place it in your Windower `addons` folder
2. In FFXI, load the addon with: `//lua load glf`
3. The addon will start automatically with default settings

## Setup for 2025 Limbus

Since Limbus was completely overhauled in June 2025, you'll need to update the zone IDs:

1. Enter Apollyon or Temenos
2. Run `//glf getzone` to see your current zone ID
3. Edit the `glf.lua` file and update the `limbus_zones` table with the correct zone IDs, or
4. Use the temporary command: `//glf addzone <zone_id> <zone_name>`

**Example:**
```
//glf getzone
// Output: Current Zone ID: 285 (Unknown Zone)
//glf addzone 285 "Apollyon - Tower"
```

## Commands

| Command | Description |
|---------|-------------|
| `//glf scan` | Manually scan for notorious monsters |
| `//glf toggle` | Enable/disable the detector |
| `//glf auto` | Toggle automatic scanning on/off |
| `//glf interval [seconds]` | Set auto-scan interval (default: 20s) |
| `//glf status` | Show current addon status and settings |
| `//glf getzone` | Display current zone ID for setup |
| `//glf addzone <id> <name>` | Temporarily add a zone ID |
| `//glf help` | Show command list |

## Configuration

The addon includes several configurable options at the top of the file:

```lua
local config = {
    enabled = true,           -- Enable/disable
