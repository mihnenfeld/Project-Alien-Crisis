extends Node2D

@onready var intro_panel: PanelContainer = $CanvasLayer/IntroPanel
@onready var choice_panel: PanelContainer = $CanvasLayer/ChoicePanel
@onready var result_panel: PanelContainer = $CanvasLayer/ResultPanel
@onready var result_text: Label = $CanvasLayer/ResultPanel/Margin/VBox/ResultText

@onready var route_a_button: Button = $CanvasLayer/IntroPanel/Margin/VBox/RouteA
@onready var route_b_button: Button = $CanvasLayer/IntroPanel/Margin/VBox/RouteB
@onready var rescue_button: Button = $CanvasLayer/ChoicePanel/Margin/VBox/Rescue
@onready var artifact_button: Button = $CanvasLayer/ChoicePanel/Margin/VBox/Artifact
@onready var return_button: Button = $CanvasLayer/ResultPanel/Margin/VBox/ReturnButton

var route: String = ""

func _ready() -> void:
    route_a_button.pressed.connect(func(): _select_route("rescue"))
    route_b_button.pressed.connect(func(): _select_route("artifact"))
    rescue_button.pressed.connect(_rescue_nyra)
    artifact_button.pressed.connect(_take_artifact)
    return_button.pressed.connect(_return_to_base)

func _select_route(selected: String) -> void:
    route = selected
    intro_panel.visible = false
    choice_panel.visible = true

    var text_node: Label = $CanvasLayer/ChoicePanel/Margin/VBox/ChoiceText
    if route == "rescue":
        text_node.text = "Die Rettungsroute führt zu einem beschädigten Außenposten. Nyra lebt noch, aber ein Alien-Artefakt wird instabil."
    else:
        text_node.text = "Die Artefaktroute führt direkt zur Quelle des Signals. Du kannst die Technologie bergen, aber Nyra wird abgeschnitten."

func _rescue_nyra() -> void:
    GameState.add_companion("Nyra")
    GameState.set_flag("nyra_rescued")
    GameState.set_flag("raid_1_complete")
    GameState.planet_stability -= 8
    GameState.last_raid_summary = "Du hast Nyra gerettet. Sie ist jetzt Begleiterin. Das Artefakt ging verloren und ein lokaler Kollaps wurde ausgelöst (-8 Stabilität, +0 Alien-Tech)."
    _show_result(GameState.last_raid_summary)

func _take_artifact() -> void:
    GameState.set_flag("nyra_dead")
    GameState.set_flag("artifact_secured")
    GameState.set_flag("raid_1_complete")
    GameState.alien_tech += 3
    GameState.resources += 20
    GameState.planet_stability -= 2
    GameState.last_raid_summary = "Du hast das Artefakt geborgen (+3 Alien-Tech, +20 Ressourcen). Nyra hat den Außenposten nicht überlebt."
    _show_result(GameState.last_raid_summary)

func _show_result(text: String) -> void:
    choice_panel.visible = false
    result_panel.visible = true
    result_text.text = text

func _return_to_base() -> void:
    get_tree().change_scene_to_file("res://scenes/base.tscn")
