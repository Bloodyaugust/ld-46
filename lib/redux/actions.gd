extends Node

onready var types = get_node('/root/action_types')

signal game_complete
signal game_restart
signal ui_click

func game_add_enemies_killed(amount):
  return {
    'type': types.GAME_ADD_ENEMIES_KILLED,
    'amount': amount
  }

func game_reset():
  return {
    'type': types.GAME_RESET
  }

func game_set_start_time(time):
  return {
    'type': types.GAME_SET_START_TIME,
    'time': time
  }

func player_damage(amount):
  return {
    'type': types.PLAYER_DAMAGE,
    'damage': amount
  }

func player_add_gold(gold):
  return {
    'type': types.PLAYER_ADD_GOLD,
    'gold': gold
  }

func player_add_upgrade(id, amount):
  return {
    'type': types.PLAYER_ADD_UPGRADE,
    'id': id,
    'amount': amount
  }

func player_reset():
  return {
    'type': types.PLAYER_RESET
  }

func player_set_gold(gold):
  return {
    'type': types.PLAYER_SET_GOLD,
    'gold': gold
  }
  
func player_set_health(health):
  return {
    'type': types.PLAYER_SET_HEALTH,
    'health': health
  }
