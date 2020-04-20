extends Sprite

onready var _viewport:Viewport = get_viewport()

var _player_damage_radius: float

func _on_store_changed(name, state)->void:
  match name:
    "player":
      _player_damage_radius = 10 + state["upgrades"].get("click-radius", 0)
      scale = Vector2(_player_damage_radius / 10, _player_damage_radius / 10)

func _ready()->void:
  store.subscribe(self, "_on_store_changed")

func _process(_delta)->void:
  global_position = _viewport.get_mouse_position()
