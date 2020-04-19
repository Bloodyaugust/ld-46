extends Area2D

onready var _collision_shape: CollisionShape2D = $"./CollisionShape2D"
onready var _tree := get_tree()

export var damage: int
export var piercing: bool
export var radius: int
export var slow: int

var _active: bool = false
var _frames_active: int = 0

func get_active()->bool:
  return _active

func set_active()->void:
  _active = true
  _frames_active = 0
  _collision_shape.shape.radius = radius
  monitoring = true

func _set_inactive()->void:
  _active = false
  monitoring = false

func _physics_process(_delta)->void:
  if _active:
    var _areas = get_overlapping_areas()

    _frames_active += 1

    for _area in _areas:
      var _area_parent = _area.get_parent()

      if _area_parent.get_class() == "Enemy":
        _area_parent.damage(damage)

        if slow > 0:
          _area_parent.slow(slow)

        if !piercing:
          _set_inactive()
          break
    
    if _frames_active > 1:
      _set_inactive()
