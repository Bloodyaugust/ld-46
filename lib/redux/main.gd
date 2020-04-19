extends Node

onready var _player_damage_circle = preload("res://behaviors/player_damage_circle.tscn")
onready var _root = get_tree().get_root()

var _player_damage:int = 1
var _player_damage_radius:int = 0
var _player_slow:int = 0
var _player_piercing:bool = false
var _player_damage_circles: Array = []

func _create_player_damage_circles()->void:
  for _i in range(10):
    _player_damage_circles.append(_player_damage_circle.instance())
    _root.add_child(_player_damage_circles[_i])

func _initialize_store()->void:
  store.dispatch(actions.game_reset())
  store.dispatch(actions.player_reset())

func _ready()->void:
  store.create([
    {'name': 'game', 'instance': reducers},
    {'name': 'player', 'instance': reducers}
  ], [
    {'name': '_on_store_changed', 'instance': self}
  ])
  store.dispatch(actions.game_set_start_time(OS.get_unix_time()))

  call_deferred("_initialize_store")
  call_deferred("_create_player_damage_circles")

  actions.connect("game_restart", self, "_initialize_store")

func _on_store_changed(name, state)->void:
  print(name, ": ", state)
  match name:
    "player":
      _player_damage = 1 + state["upgrades"].get("click-damage", 0)
      _player_damage_radius = 10 + state["upgrades"].get("click-radius", 0)
      _player_piercing = state["upgrades"].get("click-piercing", 0) > 0
      _player_slow = 0 + state["upgrades"].get("click-slow", 0)

func _unhandled_input(event)->void:
  if (event is InputEventMouseButton && event.is_pressed()) || event is InputEventScreenTouch:
    var _active_player_damage: Area2D

    for _damage_circle in _player_damage_circles:
      if !_damage_circle.get_active():
        _active_player_damage = _damage_circle
        break

    _active_player_damage.damage = _player_damage
    _active_player_damage.global_position = event.position
    _active_player_damage.piercing = _player_piercing
    _active_player_damage.radius = _player_damage_radius
    _active_player_damage.slow = _player_slow
    _active_player_damage.set_active()
