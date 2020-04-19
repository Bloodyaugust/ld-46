extends Node

onready var actions = get_node('/root/actions')
onready var reducers = get_node('/root/reducers')
onready var store = get_node('/root/store')

func _initialize_store()->void:
  store.dispatch(actions.game_reset())
  store.dispatch(actions.player_reset())

func _ready():
  store.create([
    {'name': 'game', 'instance': reducers},
    {'name': 'player', 'instance': reducers}
  ], [
    {'name': '_on_store_changed', 'instance': self}
  ])
  store.dispatch(actions.game_set_start_time(OS.get_unix_time()))

  call_deferred("_initialize_store")

  actions.connect("game_restart", self, "_initialize_store")

func _on_store_changed(name, state):
  print(name, ": ", state)
