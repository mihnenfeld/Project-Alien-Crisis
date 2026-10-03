extends Node

var resources: int = 60
var alien_tech: int = 0
var planet_stability: int = 100
var companions: Array[String] = []
var story_flags: Dictionary = {}
var last_raid_summary: String = "Noch kein Raid abgeschlossen."

func set_flag(key: String, value = true) -> void:
    story_flags[key] = value

func get_flag(key: String, default_value = false):
    return story_flags.get(key, default_value)

func add_companion(name: String) -> void:
    if name not in companions:
        companions.append(name)

func has_companion(name: String) -> bool:
    return name in companions

func reset_demo() -> void:
    resources = 60
    alien_tech = 0
    planet_stability = 100
    companions.clear()
    story_flags.clear()
    last_raid_summary = "Noch kein Raid abgeschlossen."
