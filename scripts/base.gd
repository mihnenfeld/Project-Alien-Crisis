extends Node2D

@onready var status_label: Label = $CanvasLayer/UI/Panel/Margin/VBox/Status
@onready var summary_label: Label = $CanvasLayer/UI/Panel/Margin/VBox/Summary
@onready var companion_label: Label = $CanvasLayer/UI/Panel/Margin/VBox/Companion
@onready var launch_button: Button = $CanvasLayer/UI/Panel/Margin/VBox/LaunchButton
@onready var reset_button: Button = $CanvasLayer/UI/Panel/Margin/VBox/ResetButton

func _ready() -> void:
    launch_button.pressed.connect(_launch_raid)
    reset_button.pressed.connect(_reset_demo)
    _refresh()

func _refresh() -> void:
    status_label.text = "Ressourcen: %d   Alien-Tech: %d   Planetenstabilität: %d%%" % [
        GameState.resources,
        GameState.alien_tech,
        GameState.planet_stability
    ]

    if GameState.has_companion("Nyra"):
        companion_label.text = "Begleiter: Nyra ist in der Basis."
    elif GameState.get_flag("nyra_dead"):
        companion_label.text = "Begleiter: Nyra wurde im ersten Raid nicht gerettet."
    else:
        companion_label.text = "Begleiter: Noch niemand rekrutiert."

    summary_label.text = GameState.last_raid_summary

func _launch_raid() -> void:
    if GameState.get_flag("raid_1_complete"):
        GameState.last_raid_summary = "Demo: Der erste Story-Raid ist bereits abgeschlossen."
        _refresh()
        return

    if GameState.resources < 10:
        GameState.last_raid_summary = "Zu wenig Ressourcen für die Expedition."
        _refresh()
        return

    GameState.resources -= 10
    get_tree().change_scene_to_file("res://scenes/raid.tscn")

func _reset_demo() -> void:
    GameState.reset_demo()
    _refresh()
