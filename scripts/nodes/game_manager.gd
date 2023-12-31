class_name GameManager
extends Node

@export var starting_gold: int = 50
@export var starting_cores: int = 1

@export var starting_character: String
#@export var starting_main_tower: PackedScene
#@export var starting_buildings: Array[PackedScene] = []
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
	GameUtilities.set_game_manager(self)
	Messenger.start_game_requested.connect(_on_request_start_game)

	control_debug.set_game_manager(self)

	game_data = GameData.new()

	if auto_start_game:
		start_game()


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

	game.set_player(_create_player())

	camera_2d_controller.position = map.center * GameConstants.PIXEL_SCALE
	camera_2d_controller.set_limits(
		map.width * GameConstants.PIXEL_SCALE,
		map.height * GameConstants.PIXEL_SCALE)

	entity_drawer.set_game(game)

	var player_character: PlayerCharacter = game_data.player_character_dict[starting_character]

	var params = SpawnEntityParams.new()
	params.entity_scene = player_character.main_tower.tower_scene
	params.cell = map.center_cell

	game.entities.spawn_entity(params)
	game.set_main_tower(params.spawned_entity)

	mob_spawner.start_game(game)
	main_control.start_game(game)
	control_in_game.start_game(game)
	control_debug.start_game(game)
	control_pause.start_game(game)

	pathfinding_manager.initialize_grid(width, height, GameConstants.PIXEL_SCALE)
	map_drawer.draw_map(map)

	for tower in player_character.starting_towers:
		print_debug(tower.tower_scene)
		game.building_options.add_building_option(tower.tower_scene, game.player)

	#for building in starting_buildings:
		#game.building_options.add_building_option(building, game.player)

	game.speed_changed.connect(
		func(speed: float):
			var tweens = get_tree().get_processed_tweens()

			for tween in tweens:
				tween.set_speed_scale(speed)
	)


func _create_player() -> Player:
	return Player.new(starting_gold, starting_cores)


func _generate_map(width: int, height: int) -> Map:
	var map_generator = MapGenerator.new()
	var map = map_generator.generate_map(width, height)

	MapUtilities.set_map(map)

	return map
