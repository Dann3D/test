# ng_multi_license (ESX-ready)

Simple multi-license resource scaffold that integrates with:
- ESX (es_extended) for player/currency operations
- qs-inventory (to add license item)
- ox_lib (menus/dialogs/notifications)
- oxmysql for DB

## Installation
1. Put folder `ng_multi_license` into your resources folder.
2. Add `ensure ng_multi_license` to your `server.cfg`.
3. Add `license_card` item into your qs-inventory items list.
4. Run the SQL in `schema.sql` to create the `multi_licenses` table.
5. Edit `config.lua` to add more questions, license types and locations.

## Notes
- This is a scaffold: adapt `chargePlayerByXPlayer` to match your exact ESX version/account API if needed.
- `qs-inventory:AddItem` usage may differ per qs version — adjust the TriggerEvent call if your inventory uses a different signature or callback.
- The server saves the player identifier from ESX as `citizen_id`. If you use another identifier (steam hex, license, etc.) update accordingly.
