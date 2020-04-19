extends Node2D
class_name Enemy

export var id: String

onready var _area2d = $"./Area2D"
onready var _damage_tween: Tween = $"./DamageTween"
onready var _health_bar: ProgressBar = $"./HealthBar"
onready var _sprite = $"./Sprite"
onready var _sprite_material = _sprite.material

var _current_health: int
var _damage: int
var _damage_shader_param: float = 0
var _health: int
var _speed: float
var _value: int

func damage(amount: int)->void:
  _current_health = _current_health - amount
  _health_bar.value = _current_health
  _health_bar.visible = true
  _damage_tween.interpolate_property(self, "_damage_shader_param", 1, 0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
  
  if !_damage_tween.is_active():
    _damage_tween.start()

func get_class()->String:
  return "Enemy"

func _on_area_entered(_area)->void:
  store.dispatch(actions.player_damage(_damage))
  queue_free()

func _on_input_event(_viewport, event: InputEvent, _shape_index)->void:
  if event.is_action("game_click") && event.is_action_pressed("game_click"):
    damage(1 + store.state()["player"]["upgrades"].get("click-damage", 0))

func _parse_data()->void:
  var _data: Dictionary = DataController.data["enemy"][id]
#  Eat the data into a first party data structure
  _damage = _data["damage"]
  _health = _data["health"]
  _speed = _data["speed"]
  _value = _data["value"]

  _health_bar.value = _health
  _health_bar.max_value = _health

func _process(delta)->void:
  if _current_health > 0:
    position = position + (Vector2(_speed, 0) * delta)
    _sprite_material.set_shader_param("amount", _damage_shader_param)
  else:
    store.dispatch(actions.player_add_gold(_value))
    queue_free()

func _ready()->void:
  _parse_data()

  _current_health = _health

  _area2d.connect("input_event", self, "_on_input_event")
  _area2d.connect("area_entered", self, "_on_area_entered")
