extends Node

onready var types = get_node('/root/action_types')
onready var store = get_node('/root/store')

func game(state, action):
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
    return next_state
  if action['type'] == action_types.PLAYER_ADD_UPGRADE:
    var next_state = store.shallow_copy(state)
    var _new_upgrade_value = next_state['upgrades'].get(action['id'], 0) + action['amount']
    next_state['upgrades'][action['id']] = _new_upgrade_value
    return next_state
  if action['type'] == action_types.PLAYER_RESET_UPGRADES:
    var next_state = store.shallow_copy(state)
    next_state['upgrades'] = {}
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