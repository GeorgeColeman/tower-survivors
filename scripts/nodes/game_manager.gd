class_name GameManager
extends Node

@export var game_speed: float = 1:
	get:
		return Game.speed
	set(value):
		Game.speed = value

@export var auto_start_game: bool = true

@export var map_drawer: MapDrawer
@export var mob_spawner: MobSpawner
@export var tower_spawner: TowerSpawner
@export var pathfinding_manager: Pathfinding
@export var cell_inspector: CellInspector
@export var special_effects: SpecialEffects
@export var sound_effects_player: SoundEffectsPlayer

@export_group("Control")
@export var main_control: MainControl
@export var control_in_game: ControlInGame
@export var control_debug: ControlDebug
@export var control_pause: ControlPause

@onready var camera_2d = $Camera2D

var game: Game
var game_data: GameData


func _ready():
	GameUtilities.set_game_manager(self)
	Messenger.start_game_requested.connect(_on_request_start_game)
	cell_inspector.cell_inspected.connect(_on_cell_inspected)

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

	var map_generator = MapGenerator.new()
	var map = map_generator.generate_map(width, height)

	game = Game.new(map, mob_spawner, game_data)
	GameUtilities.set_game(game)

	var tower = tower_spawner.instantiate_tower(map.center_cell)
	game.set_tower(tower)

	camera_2d.position = map.center * 16

	mob_spawner.start_game(game)

	main_control.start_game(game)
	control_in_game.start_game(game)
	control_debug.start_game(game)
	control_pause.start_game(game)

	pathfinding_manager.initialize_grid(width, height)
	map_drawer.draw_map(map)


func _on_cell_inspected(cell: Cell):
	if cell == null:
		Messenger.clicked_on_empty.emit()
		return

	var actors = GameUtilities.get_actors_at(cell)

	if actors.size() > 0:
		Messenger.clicked_on_actor.emit(actors[0])
		return

	Messenger.clicked_on_empty.emit()


