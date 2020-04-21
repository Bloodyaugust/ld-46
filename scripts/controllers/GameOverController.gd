extends Control

onready var _enemies_killed_label: Label = $"./MarginContainer/VBoxContainer/HBoxContainer/EnemiesKilledLabel"
onready var _gold_earned_label: Label = $"./MarginContainer/VBoxContainer/HBoxContainer/GoldEarnedContainer/GoldEarnedLabel"
onready var _position_tween: Tween = $"./PositionTween"
onready var _resolution_label: Label = $"./MarginContainer/VBoxContainer/ResolutionLabel"
onready var _restart_easy_button: Button = $"./MarginContainer/VBoxContainer/RestartContainer/Easy"
onready var _restart_normal_button: Button = $"./MarginContainer/VBoxContainer/RestartContainer/Normal"
onready var _score_label: Label = $"./MarginContainer/VBoxContainer/HBoxContainer/ScoreLabel"

func _get_score()->float:
  var _score: float = store.state()["game"]["enemies_killed"] * 4

  _score += store.state()["player"]["gold_earned"]
  _score *= 0.5 if SpawnController.difficulty == "easy" else 2

  return _score

func _hide()->void:
  _position_tween.interpolate_property(self, "rect_position", Vector2(100, 100), Vector2(100, 1000), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)

  if !_position_tween.is_active():
    _position_tween.start()

func _on_game_complete()->void:
  _show()

func _on_restart_button_pressed(difficulty: String)->void:
  SpawnController.difficulty = difficulty
  actions.emit_signal("game_restart")
  _hide()

func _ready()->void:
  _restart_easy_button.connect("pressed", self, "_on_restart_button_pressed", ["easy"])
  _restart_normal_button.connect("pressed", self, "_on_restart_button_pressed", ["normal"])
  actions.connect("game_complete", self, "_on_game_complete")

func _show()->void:
  _enemies_killed_label.text = "Bugs killed: {amount}".format({"amount": store.state()["game"]["enemies_killed"]})
  _gold_earned_label.text = "earned: {amount}".format({"amount": store.state()["player"]["gold_earned"]})
  _resolution_label.text = "You lost!" if store.state()["player"]["health"] <= 0 else "You won!"
  _score_label.text = "Score: {score}".format({"score": _get_score()})

  _position_tween.interpolate_property(self, "rect_position", Vector2(100, 1000), Vector2(100, 100), 0.75, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)

  if !_position_tween.is_active():
    _position_tween.start()
