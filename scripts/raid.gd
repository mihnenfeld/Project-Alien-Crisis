extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var prompt_label: Label = $CanvasLayer/Prompt
@onready var result_panel: PanelContainer = $CanvasLayer/ResultPanel
@onready var result_text: Label = $CanvasLayer/ResultPanel/Margin/VBox/ResultText
@onready var return_button: Button = $CanvasLayer/ResultPanel/Margin/VBox/ReturnButton

var current_interactable: Area2D = null
var resolved := false

func _ready() -> void:
    for interactable in get_tree().get_nodes_in_group("interactable"):
        interactable.focus_requested.connect(_on_focus_requested)
        interactable.focus_released.connect(_on_focus_released)
        interactable.interaction_requested.connect(_on_interaction_requested)

    return_button.pressed.connect(_return_to_base)
    _set_exploration_prompt()

func _process(_delta: float) -> void:
    if resolved:
        return
    if current_interactable != null and Input.is_action_just_pressed("interact"):
        current_interactable.interact()

func _on_focus_requested(interactable: Area2D) -> void:
    if resolved:
        return
    current_interactable = interactable
    prompt_label.text = interactable.prompt_text

func _on_focus_released(interactable: Area2D) -> void:
    if current_interactable == interactable:
        current_interactable = null
        _set_exploration_prompt()

func _on_interaction_requested(action_id: String) -> void:
    match action_id:
        "rescue_nyra":
            _rescue_nyra()
        "secure_artifact":
            _take_artifact()
        _:
            push_warning("Unknown interaction action: " + action_id)

func _set_exploration_prompt() -> void:
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
    current_interactable = null
    prompt_label.visible = false
    player.set_physics_process(false)
    result_text.text = text
    result_panel.visible = true

func _return_to_base() -> void:
    get_tree().change_scene_to_file("res://scenes/base.tscn")
