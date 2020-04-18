extends Node2D
class_name Enemy

export var id: String

onready var _area2d = $"./Area2D"

var _current_health: int
var _damage: int
var _health: int
var _speed: float
var _value: int

func damage(amount: int)->void:
  _current_health = _current_health - amount

func get_class()->String:
  return "Enemy"

func _on_area_entered(_area)->void:
  store.dispatch(actions.player_damage(_damage))
  queue_free()

func _on_input_event(_viewport, event: InputEvent, _shape_index)->void:
  if event.is_action("game_click") && event.is_action_pressed("game_click"):
    damage(1)

func _parse_data()->void:
  var _data: Dictionary = DataController.data["enemy"][id]
#  Eat the data into a first party data structure
  _damage = _data["damage"]
  _health = _data["health"]
  _speed = _data["speed"]
  _value = _data["value"]

func _process(delta)->void:
  if _current_health > 0:
    position = position + (Vector2(_speed, 0) * delta)
  else:
    store.dispatch(actions.player_add_gold(_value))
    queue_free()

func _ready()->void:
  _parse_data()

  _current_health = _health

  _area2d.connect("input_event", self, "_on_input_event")
  _area2d.connect("area_entered", self, "_on_area_entered")
