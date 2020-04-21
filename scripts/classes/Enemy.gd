extends Node2D
class_name Enemy

const SLOW_DURATION_BASE: float = 1.0

export var id: String
export var hop_position: Vector2 = Vector2(0, 0)

onready var _animation_player: AnimationPlayer = $"./AnimationPlayer"
onready var _area2d = $"./Area2D"
onready var _collision_shape = $"./Area2D/CollisionShape2D"
onready var _damage_tween: Tween = $"./DamageTween"
onready var _floating_text: PackedScene = preload("res://doodads/floating_text.tscn")
onready var _health_bar: ProgressBar = $"./HealthBarContainer/HealthBar"
onready var _one_shot_sfx: PackedScene = preload("res://behaviors/one_shot_sfx.tscn")
onready var _random_offset: float = rand_range(0, 5000)
onready var _sfx: Dictionary = {
  "aphid": preload("res://resources/sfx/bug-squish.wav"),
  "bird": preload("res://resources/sfx/bird-squawk.wav"),
  "clappap": preload("res://resources/sfx/bug-squish.wav"),
  "grasshopper": preload("res://resources/sfx/bug-crunch.wav"),
  "snail": preload("res://resources/sfx/bug-crunch.wav")
}
onready var _sprite = $"./Sprite"
onready var _sprite_material = _sprite.material
onready var _tree := get_tree()
onready var _root := _tree.get_root()

var _current_health: int
var _damage: int
var _damage_shader_param: float = 0
var _health: int
var _last_position: Vector2
var _movement_type: String
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

func slow(amount: int)->void:
  _slow_duration_left = SLOW_DURATION_BASE * amount

func get_class()->String:
  return "Enemy"

func _die()->void:
  var _new_one_shot = _one_shot_sfx.instance()

  _new_one_shot.global_position = global_position
  _new_one_shot.stream_resource = _sfx[id]

  _root.add_child(_new_one_shot)

  queue_free()

func _on_animation_ended()->void:
  _last_position = global_position
  hop_position = Vector2(0, 0)

func _on_area_entered(area)->void:
  if area.is_in_group("Plant"):
    store.dispatch(actions.player_damage(_damage))
    _die()

func _parse_data()->void:
  var _data: Dictionary = DataController.data["enemy"][id]
  var _hop_animation: Animation = _animation_player.get_animation("hop")
#  Eat the data into a first party data structure
  _damage = _data["damage"]
  _health = _data["health"]
  _movement_type = _data["movement"]
  _value = _data["value"]

  _speed = _data["speed"]
  if _movement_type == "hop":
    _hop_animation.track_set_key_value(1, 1, [_speed, -0.25, 0, 0.25, 0])

  _sprite.texture = load("res://sprites/enemies/{id}.png".format({"id": id}))
  _collision_shape.shape.extents = Vector2(_data["size"][0], _data["size"][1])
  _health_bar.rect_size = Vector2(_data["size"][0] * 2, 7)
  _health_bar.rect_position = Vector2(-_data["size"][0], -_data["size"][1] - 14)

  _health_bar.value = _health
  _health_bar.max_value = _health

func _process(delta)->void:
  if _current_health > 0:
    if _slow_duration_left > 0:
      _slow_duration_left -= delta
      
      if _slow_amount == 0:
        _slow_amount = store.state()["player"]["upgrades"].get("click-slow", 0) * 0.35
    else:
      _slow_duration_left = 0
      _slow_amount = 0

    match _movement_type:
      "fly":
        var _sin_scalar: float = sin((OS.get_system_time_msecs() + _random_offset) / 100)

        if _animation_player.current_animation != "fly":
          _animation_player.play("fly")

        position = position + (Vector2(_speed, _sin_scalar * 300) * delta) - (Vector2(_speed, _sin_scalar * 300) * delta * _slow_amount)
      "hop":
        if _animation_player.current_animation != "hop":
          _animation_player.play("hop")
        global_position = _last_position + hop_position
      "squish":
        var _sin_scalar: float = (sin((OS.get_system_time_msecs() + _random_offset) / 200.0) + 1.0) / 2.0

        position = position + (Vector2(_sin_scalar * _speed, 0) * delta) - (Vector2(_sin_scalar * _speed, 0) * delta * _slow_amount)
        _sprite.scale.x = 0.75 + (_sin_scalar * 0.25)
      "basic":
        if _animation_player.current_animation != "basic":
          _animation_player.play("basic")
        position = position + (Vector2(_speed, 0) * delta) - (Vector2(_speed, 0) * delta * _slow_amount)

    _sprite_material.set_shader_param("amount", _damage_shader_param)
    if _slow_duration_left > 0:
      _sprite_material.set_shader_param("slow_amount", _slow_duration_left / (SLOW_DURATION_BASE * store.state()["player"]["upgrades"].get("click-slow", 0)))
    else:
      _sprite_material.set_shader_param("slow_amount", 0)

  else:
    var _new_floating_text = _floating_text.instance()
    var _gold_added = _value + store.state()["player"]["upgrades"].get("enemy-kill-bonus-gold", 0)

    _gold_added += 2 if SpawnController.difficulty == "easy" else 0

    store.dispatch(actions.player_add_gold(_gold_added))
    store.dispatch(actions.game_add_enemies_killed(1))

    _new_floating_text.get_node("Label").text = str(_gold_added)
    _new_floating_text.global_position = global_position - Vector2(0, 10)
    _new_floating_text.time_to_live = 1
    _new_floating_text.float_speed = 100

    _tree.get_root().add_child(_new_floating_text)

    _die()

func _ready()->void:
  _parse_data()

  _current_health = _health
  _last_position = global_position

  _area2d.connect("area_entered", self, "_on_area_entered")
