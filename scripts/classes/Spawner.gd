extends Node2D
class_name Spawner

signal spawner_spawning_completed

export var configuration: Dictionary

onready var _enemy_actor: PackedScene = preload("res://actors/Enemy.tscn")
onready var _root := get_tree().get_root()

var _delay: float
var _enemy_id: String
var _spawning: bool = false
var _spawn_interval: float = 0
var _spawns_left: int
var _time_to_start_spawning: float
var _time_to_spawn: float

func get_class()->String:
  return "Spawner"

func _parse_configuration()->void:
  _delay = configuration.delay
  _enemy_id = configuration.id
  _spawn_interval = configuration.interval
  _spawns_left = configuration.count
  _time_to_start_spawning = _delay
  _time_to_spawn = _spawn_interval

func _process(delta)->void:
  if _spawning:

    if _time_to_start_spawning > 0:
      _time_to_start_spawning -= delta

    else:
      _time_to_spawn -= delta

      if _time_to_spawn <= 0:
        _spawn()

        if _spawns_left == 0:
          emit_signal("spawner_spawning_completed")
          queue_free()

  else:
    _time_to_start_spawning -= delta

    if _time_to_start_spawning <= 0:
      _spawning = true

func _ready()->void:
  add_to_group("Spawners")
  _parse_configuration()

func _spawn()->void:
  var _new_enemy = _enemy_actor.instance()

  _new_enemy.id = _enemy_id
  _new_enemy.global_position = global_position + Vector2(0, rand_range(-50, 50))

  _root.add_child(_new_enemy)

  _spawns_left -= 1
  _time_to_spawn = _spawn_interval
