extends Control

onready var _player_gold_label: Label = $"./PlayerGoldLabel"

var _player_gold: int = 0

func _on_store_changed(name, state)->void:
  match name:
    "player":
      _player_gold = state["gold"]

      _update_screen()

func _ready()->void:
  store.subscribe(self, "_on_store_changed")

func _update_screen()->void:
  _player_gold_label.text = str(_player_gold)
