class_name GameManager
extends Node

@export var game_speed: float = 1:
	get:
		return Game.speed
	set(value):
		Game.speed = value

@export var starting_gold: int = 50
@export var starting_main_tower: PackedScene
@export var starting_buildings: Array[PackedScene] = []
@export var auto_start_game: bool = true

@export var camera_2d_controller: Camera2DController
@export var map_drawer: MapDrawer
@export var mob_spawner: MobSpawner
@export var entity_drawer: EntityDrawer
@export var pathfinding_manager: PathfindingManager
@export var vfx_drawer_2d: VFXDrawer2D
@export var sound_effects_player: SoundEffectsPlayer

@export_group("Control")
@export var main_control: MainControl
@export var control_in_game: ControlInGame
@export var control_debug: ControlDebug
@export var control_pause: ControlPause

var game: Game
var game_data: GameData


func _ready():
	_config_test()

	GameUtilities.set_game_manager(self)
	Messenger.start_game_requested.connect(_on_request_start_game)

	control_debug.set_game_manager(self)

	game_data = GameData.new()

	if auto_start_game:
		start_game()


func _config_test():
	var config = ConfigFile.new()
	var err = config.load("res://config/tower_weapons.cfg")

	if err != OK:
		push_warning("Err is not ok")

		return

	for element in config.get_sections():
		#print_debug(element)
		var damage = config.get_value(element, "damage")
		var effects = config.get_value(element, "effects")
		var scene_path = config.get_value(element, "proj_scene_path")

		if effects.has("type"):
			match effects["type"]:
				"burn":
					var eff = WeaponEffectBurn.new(
						effects["damage"],
						Enums.get_weapon_effect_apply_type(effects["apply_type"])
					)
					print_debug(eff)
				"slow":
					var eff = WeaponEffectSlow.new(
						effects["factor"],
						effects["duration"],
						Enums.get_weapon_effect_apply_type(effects["apply_type"])
					)
					print_debug(eff)

		#var scene: PackedScene = load(scene_path)
		#print_debug(scene)
#
		#var node = scene.instantiate()
		#add_child(node)

		#print_debug(effects.has("apply_type"))
		#print_debug(str(element, " :: ", damage, " :: ", effects))


func _on_request_start_game():
	start_game()


func _process(delta):
	if game == null:
		return

	game.process(delta)


func start_game():
	var width: int = 32
	var height: int = 32

	var map = _generate_map(width, height)

	game = Game.new(map, mob_spawner, game_data)
	GameUtilities.set_game(game)

	game.set_player(Player.new(starting_gold))

	camera_2d_controller.position = map.center * GameConstants.PIXEL_SCALE
	camera_2d_controller.set_limits(
		map.width * GameConstants.PIXEL_SCALE,
		map.height * GameConstants.PIXEL_SCALE)

	entity_drawer.set_game(game)

	var params = SpawnEntityParams.new()
	params.entity_scene = starting_main_tower
	params.cell = map.center_cell
	Entities.spawn_entity(params)

	game.set_main_tower(params.spawned_entity)

	mob_spawner.start_game(game)

	main_control.start_game(game)
	control_in_game.start_game(game)
	control_debug.start_game(game)
	control_pause.start_game(game)

	pathfinding_manager.initialize_grid(width, height, GameConstants.PIXEL_SCALE)
	map_drawer.draw_map(map)

	for building in starting_buildings:
		game.building_options.add_building_option_packed(building)


func _generate_map(width: int, height: int) -> Map:
	var map_generator = MapGenerator.new()
	var map = map_generator.generate_map(width, height)

	MapUtilities.set_map(map)

	return map
