extends Node

signal spawn_controller_spawn_wave
signal spawn_controller_wave_complete

onready var _tree := get_tree()
onready var _root := _tree.get_root()

var _current_wave: int = 0
var _game_complete: bool = false
var _spawners_remaining: int = 0
var _spawn_points: Dictionary = {}
var _waiting_for_next_wave: bool = false

func _on_game_complete()->void:
  _game_complete = true

func _on_game_restart()->void:
  _current_wave = 0
  _game_complete = false
  _spawners_remaining = 0
  _spawn_wave()

func _on_spawner_spawning_completed()->void:
  print("Spawner finished")
  _spawners_remaining -= 1

  if _spawners_remaining == 0:
    _waiting_for_next_wave = true
    print("Spawners all finished")

func _process(delta)->void:
  if _waiting_for_next_wave:
    var _enemies = _tree.get_nodes_in_group("Enemy")

    if _enemies.size() == 0:
      _current_wave += 1
      _waiting_for_next_wave = false
      print("Wave complete")

      if _current_wave == DataController.data["waves"]["normal"].size():
        actions.emit_signal("game_complete")
      else:
        emit_signal("spawn_controller_wave_complete")

  if store.state()["player"]["health"] <= 0 && !_game_complete:
    var _enemies = _tree.get_nodes_in_group("Enemy")
    var _spawners = _tree.get_nodes_in_group("Spawners")

    _waiting_for_next_wave = false
    actions.emit_signal("game_complete")
    print("Player lost")

    for _enemy in _enemies:
      _enemy.queue_free()
    for _spawner in _spawners:
      _spawner.queue_free()

func _ready()->void:
  _spawn_points["top"] = Vector2(-100, 150)
  _spawn_points["middle"] = Vector2(-100, 300)
  _spawn_points["bottom"] = Vector2(-100, 450)

  connect("spawn_controller_spawn_wave", self, "_spawn_wave")
  actions.connect("game_complete", self, "_on_game_complete")
  actions.connect("game_restart", self, "_on_game_restart")

  call_deferred("_spawn_wave")

func _spawn_wave()->void:
  var _new_spawner: Spawner
  var _wave: Array = DataController.data["waves"]["normal"][_current_wave]

  for _spawn_configuration in _wave:
    _new_spawner = Spawner.new()

    _new_spawner.global_position = _spawn_points[_spawn_configuration.location]
    _new_spawner.configuration = _spawn_configuration

    _new_spawner.connect("spawner_spawning_completed", self, "_on_spawner_spawning_completed")

    _root.add_child(_new_spawner)
    _spawners_remaining += 1
