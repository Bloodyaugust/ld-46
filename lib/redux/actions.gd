extends Node

onready var types = get_node('/root/action_types')

signal player_damaged
signal player_tile_changed

func game_set_start_time(time):
  return {
    'type': types.GAME_SET_START_TIME,
    'time': time
  }

func player_damage(amount):
  emit_signal("player_damaged")
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

func player_reset_upgrades():
  return {
    'type': types.PLAYER_RESET_UPGRADES
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
