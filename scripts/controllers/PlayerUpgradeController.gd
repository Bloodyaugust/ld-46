extends Control

onready var _next_round_button: Button = $"./MarginContainer/VBoxContainer/CenterContainer/NextRound"
onready var _top_margin_tween: Tween = $"./TopMarginTween"
onready var _upgrade_container: GridContainer = $"./MarginContainer/VBoxContainer/UpgradeContainer"
onready var _upgrade_scene: PackedScene = preload("res://ui/elements/Upgrade.tscn")

var _player_gold: int = 0

func _on_next_round_pressed()->void:
  SpawnController.emit_signal("spawn_controller_spawn_wave")
  _hide()

func _on_store_changed(name, state)->void:
  match name:
    "player":
      _player_gold = state["gold"]

      _update_screen()

func _on_spawn_controller_wave_complete()->void:
  _show()

func _on_upgrade_button_pressed(id)->void:
  print("Upgrade pressed for: " + id)

func _populate()->void:
  for _upgrade in DataController.data["upgrades"]["player"]:
    var _new_upgrade = _upgrade_scene.instance()
    var _new_upgrade_button = _new_upgrade.get_node("Button")

    _new_upgrade.name = _upgrade.id
    _new_upgrade.get_node("Button").text = _upgrade.label
    _new_upgrade.get_node("Cost").text = str(_upgrade.cost)
    _new_upgrade.get_node("Current").text = str(0)
    _new_upgrade_button.hint_tooltip = _upgrade.description

    _new_upgrade_button.connect("pressed", self, "_on_upgrade_button_pressed", [_upgrade.id])

    _upgrade_container.add_child(_new_upgrade)

func _ready()->void:
  store.subscribe(self, "_on_store_changed")
  SpawnController.connect("spawn_controller_wave_complete", self, "_on_spawn_controller_wave_complete")
  call_deferred("_populate")

func _show()->void:
  _top_margin_tween.interpolate_property(self, "rect_position", Vector2(100, 1000), Vector2(100, 100), 0.75, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)

  if !_top_margin_tween.is_active():
    _top_margin_tween.start()

func _hide()->void:
  _top_margin_tween.interpolate_property(self, "rect_position", Vector2(100, 100), Vector2(100, 1000), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)

  if !_top_margin_tween.is_active():
    _top_margin_tween.start()

func _update_screen()->void:
  var _player_upgrades = DataController.data["upgrades"]["player"]

  for _upgrade in _player_upgrades:
    var _upgrade_element = _upgrade_container.get_node(_upgrade.id)
    var _upgrade_button = _upgrade_element.get_node("Button")

    if _upgrade_element:
      if _player_gold < _upgrade.cost:
        _upgrade_button.disabled = true
      else:
        _upgrade_button.disabled = false
