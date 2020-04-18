extends Control

onready var _player_healthbar: ProgressBar = $"./PanelContainer/PlayerHealthbar"
onready var _player_health_label: Label = $"./PanelContainer/CenterContainer/PlayerHealthLabel"

var _player_health: int = 0

func _on_store_changed(name, state)->void:
  match name:
    "player":
      _player_health = state["health"]

      _update_screen()

func _ready()->void:
  store.subscribe(self, "_on_store_changed")

func _update_screen()->void:
  _player_healthbar.value = _player_health
  _player_health_label.text = "{_player_health}/100".format({"_player_health": _player_health})
