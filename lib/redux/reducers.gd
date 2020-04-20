extends Node

onready var types = get_node('/root/action_types')
onready var store = get_node('/root/store')

func game(state, action):
  if action['type'] == action_types.GAME_ADD_ENEMIES_KILLED:
    var next_state = store.shallow_copy(state)
    next_state['enemies_killed'] = next_state['enemies_killed'] + action['amount']
    return next_state
  if action['type'] == action_types.GAME_RESET:
    var next_state = {
      "enemies_killed": 0,
      "start_time": store.shallow_copy(state)['start_time']
    }
    return next_state
  if action['type'] == action_types.GAME_SET_START_TIME:
    var next_state = store.shallow_copy(state)
    next_state['start_time'] = action['time']
    return next_state
  return state

func player(state, action):
  if action['type'] == action_types.PLAYER_DAMAGE:
    var next_state = store.shallow_copy(state)
    next_state['health'] = next_state['health'] - action['damage']
    return next_state
  if action['type'] == action_types.PLAYER_ADD_GOLD:
    var next_state = store.shallow_copy(state)
    next_state['gold'] = next_state['gold'] + action['gold']
    if action['gold'] > 0:
      next_state['gold_earned'] = next_state['gold_earned'] + action['gold']
    return next_state
  if action['type'] == action_types.PLAYER_ADD_UPGRADE:
    var next_state = store.shallow_copy(state)
    var _new_upgrade_value = next_state['upgrades'].get(action['id'], 0) + action['amount']
    next_state['upgrades'][action['id']] = _new_upgrade_value
    return next_state
  if action['type'] == action_types.PLAYER_RESET:
    var next_state = {
      "gold": 0,
      "gold_earned": 0,
      "health": 100,
      "upgrades": {}
      # "upgrades": {"click-damage": 3, "click-piercing": 1, "click-slow": 1, "click-radius": 20}
    }
    return next_state
  if action['type'] == action_types.PLAYER_SET_GOLD:
    var next_state = store.shallow_copy(state)
    next_state['gold'] = action['gold']
    return next_state
  if action['type'] == action_types.PLAYER_SET_HEALTH:
    var next_state = store.shallow_copy(state)
    next_state['health'] = action['health']
    return next_state
  return state