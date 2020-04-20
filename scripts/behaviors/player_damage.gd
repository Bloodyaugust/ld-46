extends Area2D

onready var _animation_player: AnimationPlayer = $"./Sprite/AnimationPlayer"
onready var _collision_shape: CollisionShape2D = $"./CollisionShape2D"
onready var _sprite: Sprite = $"./Sprite"
onready var _tree := get_tree()

export var damage: int
export var piercing: bool
export var radius: int
export var slow: int

var _active: bool = false
var _animations: Array = [
  "poke",
  "poke",
  "poke",
  "punch",
  "punch",
  "spray"
]
var _damage_active: bool = false
var _frames_active: int = 0
var _sprite_textures: Array = [
  load("res://sprites/attacks/poke.png"),
  load("res://sprites/attacks/poke.png"),
  load("res://sprites/attacks/poke.png"),
  load("res://sprites/attacks/punch.png"),
  load("res://sprites/attacks/punch.png"),
  load("res://sprites/attacks/insecticide.png")
]

func get_active()->bool:
  return _active

func set_active()->void:
  _active = true
  _damage_active = true
  _frames_active = 0
  _collision_shape.shape.radius = radius
  monitoring = true

  _sprite.texture = _sprite_textures[damage - 1]
  _sprite.visible = true
  _animation_player.play(_animations[damage - 1])

func _set_damage_inactive()->void:
  _damage_active = false
  monitoring = false

func _set_inactive()->void:
  _active = false
  _sprite.visible = false

func _physics_process(_delta)->void:
  if _damage_active:
    var _areas = get_overlapping_areas()

    _frames_active += 1

    for _area in _areas:
      var _area_parent = _area.get_parent()

      if _area_parent.get_class() == "Enemy":
        _area_parent.damage(damage)

        if slow > 0:
          _area_parent.slow(slow)

        if !piercing:
          _set_damage_inactive()
          break
    
    if _frames_active > 1:
      _set_damage_inactive()

func _ready()->void:
  _set_inactive()
