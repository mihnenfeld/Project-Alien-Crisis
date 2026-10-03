extends Area2D

signal interaction_requested(action_id: String)
signal focus_requested(interactable: Area2D)
signal focus_released(interactable: Area2D)

@export var prompt_text: String = "Drücke E zum Interagieren."
@export var action_id: String = ""
@export var one_shot: bool = true

var _used := false

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func interact() -> void:
    if _used:
        return
    interaction_requested.emit(action_id)
    if one_shot:
        _used = true
        monitoring = false

func _on_body_entered(body: Node) -> void:
    if body is CharacterBody2D and not _used:
        focus_requested.emit(self)

func _on_body_exited(body: Node) -> void:
    if body is CharacterBody2D:
        focus_released.emit(self)
