extends Control

onready var _player_healthbar: ProgressBar = $"./PanelContainer/PlayerHealthbar"

var _player_health: int = 0

func _on_store_changed(name, state):
  match name:
    "player":
      _player_health = state["health"]

      _update_screen()

func _ready():
  store.subscribe(self, "_on_store_changed")

func _update_screen():
  _player_healthbar.value = _player_health
