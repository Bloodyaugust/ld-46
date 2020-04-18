extends Node

onready var _root := get_tree().get_root()

var _current_wave: int = 0
var _spawn_points: Dictionary = {}

func _ready()->void:
  _spawn_points["top"] = Vector2(-100, 150)
  _spawn_points["middle"] = Vector2(-100, 300)
  _spawn_points["bottom"] = Vector2(-100, 450)

  call_deferred("_spawn_wave")

func _spawn_wave()->void:
  var _new_spawner: Spawner
  var _wave: Array = DataController.data["waves"]["normal"][_current_wave]

  for _spawn_configuration in _wave:
    _new_spawner = Spawner.new()

    _new_spawner.global_position = _spawn_points[_spawn_configuration.location]
    _new_spawner.configuration = _spawn_configuration

    _root.add_child(_new_spawner)
