class_name DataUtilities

static var _game_data: GameData


static func init(game_data: GameData):
	_game_data = game_data


static func get_weapon_data(weapon_name: String) -> TowerWeaponData:
	return _game_data.get_tower_weapon_data(weapon_name)
