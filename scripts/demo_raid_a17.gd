extends "res://scripts/demo_ctb.gd"
## Freshly instantiated raid map with a manual evacuation point.
const EVAC_POINT := Vector2(140, 557)
const EVAC_RADIUS := 95.0

func _ready() -> void:
    super._ready()
    player = Vector2(220, 447)
    title_label.text = "ALIEN CRISIS / RAID: OUTPOST A-17"
    hint_label.text = "WASD BEWEGEN | SHIFT SPRINTEN | E INTERAGIEREN / EVAC | ESC ENDE"
    announcement = "RAID A-17. EVAC-PUNKT IM WESTFLUEGEL. GENERATOR / SCHOTT / ALIEN UNTERSUCHEN."
    _update_status()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if not battle_active and event.keycode == KEY_E and player.distance_to(EVAC_POINT) < EVAC_RADIUS:
        get_tree().change_scene_to_file("res://scenes/demo_base_hub.tscn")
        return
    super._unhandled_key_input(event)

func _draw() -> void:
    super._draw()
    # Pulsing beacon and overhead maintenance pipes for an industrial depth layer.
    var beacon: float = 0.45 + 0.35 * sin(ambience_time * 3.0)
    draw_circle(Vector2(1162, 186), 18, Color(0.95, 0.26, 0.17, beacon * 0.28))
    draw_circle(Vector2(1162, 186), 5, Color(1.0, 0.39, 0.20, beacon))
    for offset in [0, 10, 20]:
        draw_line(Vector2(85 + offset, 169), Vector2(85 + offset, 312), Color("#4b6670"), 5)
    draw_circle(EVAC_POINT + Vector2(6, 8), 46, Color(0, 0, 0, 0.42))
    _surface("evac", Rect2(EVAC_POINT - Vector2(48, 48), Vector2(96, 96)), 0.90)
    draw_circle(EVAC_POINT, 42, Color(0.10, 0.72, 0.56, 0.17))
    draw_arc(EVAC_POINT, 31, 0, TAU, 40, Color("#77f4c7"), 3, true)
    draw_line(EVAC_POINT + Vector2(-19, 0), EVAC_POINT + Vector2(19, 0), Color("#77f4c7"), 2)
    draw_line(EVAC_POINT + Vector2(0, -19), EVAC_POINT + Vector2(0, 19), Color("#77f4c7"), 2)
    if player.distance_to(EVAC_POINT) < EVAC_RADIUS and not battle_active:
        draw_arc(EVAC_POINT, 49, 0, TAU, 40, Color("#d8ffee"), 3, true)
