extends Control

export var music_disabled_texture: Texture
export var music_enabled_texture: Texture
export var sfx_disabled_texture: Texture
export var sfx_enabled_texture: Texture

onready var _bus_music_index: int = AudioServer.get_bus_index("Music")
onready var _bus_sfx_index: int = AudioServer.get_bus_index("SFX")
onready var _toggle_music: TextureRect = $"./ToggleMusic"
onready var _toggle_sfx: TextureRect = $"./ToggleSFX"

func _on_ToggleMusic_gui_input(event: InputEvent)->void:
  if (event is InputEventMouseButton && event.is_pressed()) || event is InputEventScreenTouch:
    AudioServer.set_bus_mute(_bus_music_index, !AudioServer.is_bus_mute(_bus_music_index))
    _toggle_music.texture = music_disabled_texture if AudioServer.is_bus_mute(_bus_music_index) else music_enabled_texture

func _on_ToggleSFX_gui_input(event: InputEvent)->void:
  if (event is InputEventMouseButton && event.is_pressed()) || event is InputEventScreenTouch:
    AudioServer.set_bus_mute(_bus_sfx_index, !AudioServer.is_bus_mute(_bus_sfx_index))
    _toggle_sfx.texture = sfx_disabled_texture if AudioServer.is_bus_mute(_bus_sfx_index) else sfx_enabled_texture
