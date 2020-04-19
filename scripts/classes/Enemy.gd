extends Node2D
class_name Enemy

const SLOW_DURATION_BASE: float = 1.0

export var id: String

onready var _area2d = $"./Area2D"
onready var _damage_tween: Tween = $"./DamageTween"
onready var _floating_text: PackedScene = preload("res://doodads/floating_text.tscn")
onready var _health_bar: ProgressBar = $"./HealthBar"
onready var _sprite = $"./Sprite"
onready var _sprite_material = _sprite.material
onready var _tree := get_tree()

var _current_health: int
var _damage: int
var _damage_shader_param: float = 0
var _health: int
var _slow_amount: float
var _slow_duration_left: float
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

    if store.state()["player"]["upgrades"].get("click-slow", 0) > 0:
      _slow_duration_left = SLOW_DURATION_BASE * store.state()["player"]["upgrades"].get("click-slow", 0)

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
    if _slow_duration_left > 0:
      _slow_duration_left -= delta
      
      if _slow_amount == 0:
        _slow_amount = store.state()["player"]["upgrades"].get("click-slow", 0) * 0.1
    else:
      _slow_duration_left = 0
      _slow_amount = 0

    position = position + (Vector2(_speed, 0) * delta) - (Vector2(_speed, 0) * delta * _slow_amount)
    _sprite_material.set_shader_param("amount", _damage_shader_param)
    if _slow_duration_left > 0:
      _sprite_material.set_shader_param("slow_amount", _slow_duration_left / (SLOW_DURATION_BASE * store.state()["player"]["upgrades"].get("click-slow", 0)))
    else:
      _sprite_material.set_shader_param("slow_amount", 0)

  else:
    var _new_floating_text = _floating_text.instance()
    var _gold_added = _value + store.state()["player"]["upgrades"].get("enemy-kill-bonus-gold", 0)

    store.dispatch(actions.player_add_gold(_gold_added))
    store.dispatch(actions.game_add_enemies_killed(1))

    _new_floating_text.get_node("Label").text = str(_gold_added)
    _new_floating_text.global_position = global_position - Vector2(0, 10)
    _new_floating_text.time_to_live = 1
    _new_floating_text.float_speed = 100

    _tree.get_root().add_child(_new_floating_text)

    queue_free()

func _ready()->void:
  _parse_data()

  _current_health = _health

  _area2d.connect("input_event", self, "_on_input_event")
  _area2d.connect("area_entered", self, "_on_area_entered")
