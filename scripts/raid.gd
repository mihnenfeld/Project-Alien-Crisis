extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var prompt_label: Label = $CanvasLayer/Prompt
@onready var result_panel: PanelContainer = $CanvasLayer/ResultPanel
@onready var result_text: Label = $CanvasLayer/ResultPanel/Margin/VBox/ResultText
@onready var return_button: Button = $CanvasLayer/ResultPanel/Margin/VBox/ReturnButton
@onready var rescue_zone: Area2D = $RescueZone
@onready var artifact_zone: Area2D = $ArtifactZone

var nearby_route: String = ""
var resolved := false

func _ready() -> void:
    rescue_zone.body_entered.connect(func(body): _on_zone_entered(body, "rescue"))
    rescue_zone.body_exited.connect(func(body): _on_zone_exited(body, "rescue"))
    artifact_zone.body_entered.connect(func(body): _on_zone_entered(body, "artifact"))
    artifact_zone.body_exited.connect(func(body): _on_zone_exited(body, "artifact"))
    return_button.pressed.connect(_return_to_base)
    prompt_label.text = "Erkunde den Raid. Links: Rettungssignal. Rechts: Alien-Signal."

func _process(_delta: float) -> void:
    if resolved:
        return
    if nearby_route != "" and Input.is_action_just_pressed("interact"):
        if nearby_route == "rescue":
            _rescue_nyra()
        elif nearby_route == "artifact":
            _take_artifact()

func _on_zone_entered(body: Node, route_name: String) -> void:
    if body != player or resolved:
        return
    nearby_route = route_name
    if route_name == "rescue":
        prompt_label.text = "Nyra lebt noch. Drücke E, um sie zu retten."
    else:
        prompt_label.text = "Das Artefakt ist instabil. Drücke E, um es zu sichern."

func _on_zone_exited(body: Node, route_name: String) -> void:
    if body != player or resolved:
        return
    if nearby_route == route_name:
        nearby_route = ""
        prompt_label.text = "Erkunde den Raid. Links: Rettungssignal. Rechts: Alien-Signal."

func _rescue_nyra() -> void:
    resolved = true
    GameState.add_companion("Nyra")
    GameState.set_flag("nyra_rescued")
    GameState.set_flag("raid_1_complete")
    GameState.planet_stability -= 8
    GameState.last_raid_summary = "Du hast Nyra gerettet. Sie ist jetzt Begleiterin. Das Artefakt ging verloren und ein lokaler Kollaps wurde ausgelöst (-8 Stabilität, +0 Alien-Tech)."
    _show_result(GameState.last_raid_summary)

func _take_artifact() -> void:
    resolved = true
    GameState.set_flag("nyra_dead")
    GameState.set_flag("artifact_secured")
    GameState.set_flag("raid_1_complete")
    GameState.alien_tech += 3
    GameState.resources += 20
    GameState.planet_stability -= 2
    GameState.last_raid_summary = "Du hast das Artefakt geborgen (+3 Alien-Tech, +20 Ressourcen). Nyra hat den Außenposten nicht überlebt."
    _show_result(GameState.last_raid_summary)

func _show_result(text: String) -> void:
    nearby_route = ""
    prompt_label.visible = false
    player.set_physics_process(false)
    result_text.text = text
    result_panel.visible = true

func _return_to_base() -> void:
    get_tree().change_scene_to_file("res://scenes/base.tscn")
