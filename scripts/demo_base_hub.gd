extends "res://scripts/demo_outpost.gd"
## Playable two-room underground base. The east lift loads the raid as a new scene.
const LIFT := Rect2(1030, 293, 114, 118)
const LIFT_ENTRY := Vector2(1024, 352)

func _ready() -> void:
    super._ready()
    player = Vector2(225, 456)
    gate_open = true
    gate_released = true
    title_label.text = "ALIEN CRISIS / UNTERGRUNDBASIS"
    hint_label.text = "WASD LAUFEN  |  E AM AUFZUG: RAID A-17  |  ESC ENDE"
    announcement = "KOMMANDORAUM WEST / WERKSTATT OST / AUFZUG ZUR OBERWELT"
    _update_status()

func _blocked(test: Vector2) -> bool:
    if not FLOOR.grow(-28).has_point(test):
        return true
    # The central wall has an open, unobstructed passage.
    for obstacle in BLOCKS:
        if obstacle.grow(16).has_point(test):
            return true
    if LIFT.grow(5).has_point(test):
        return true
    return false

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_ESCAPE:
        get_tree().quit()
    elif event.keycode == KEY_E:
        if player.distance_to(LIFT_ENTRY) < 155:
            get_tree().change_scene_to_file("res://scenes/demo_raid_a17.tscn")
        else:
            announcement = "AUFZUG IM OSTFLUEGEL AUFSUCHEN."
            _update_status()

func _draw() -> void:
    draw_rect(FLOOR, Color("#121d29"))
    draw_rect(Rect2(80, 122, 644, 516), Color("#1c303b"))
    draw_rect(Rect2(748, 122, 452, 516), Color("#263039"))
    for x in range(80, 1200, 32):
        draw_line(Vector2(x, 122), Vector2(x, 638), Color("#31434b"), 1)
    for y in range(122, 638, 32):
        draw_line(Vector2(80, y), Vector2(1200, y), Color("#31434b"), 1)
    draw_rect(Rect2(115, 174, 300, 110), Color("#334956"))
    draw_rect(Rect2(135, 193, 260, 70), Color("#0c2b37"))
    draw_rect(Rect2(154, 211, 210, 8), Color("#59bbb8"))
    draw_rect(Rect2(154, 236, 145, 6), Color("#426b78"))
    draw_rect(Rect2(170, 508, 200, 70), Color("#3f4b54"))
    draw_rect(Rect2(180, 518, 180, 50), Color("#17242c"))
    draw_rect(Rect2(821, 190, 115, 95), Color("#42545b"))
    draw_rect(Rect2(839, 207, 79, 58), Color("#123e47"))
    draw_rect(Rect2(855, 223, 46, 8), Color("#5edaca"))
    draw_rect(Rect2(839, 490, 117, 62), Color("#51545a"))
    # Lift with unmistakable teal destination indicator.
    draw_rect(LIFT, Color("#465861"))
    draw_rect(LIFT.grow(-9), Color("#091d2b"))
    draw_rect(Rect2(1048, 311, 79, 12), Color("#69dbc3"))
    draw_rect(Rect2(1065, 343, 46, 40), Color("#334c54"))
    draw_line(Vector2(1088, 343), Vector2(1088, 383), Color("#8eb2b7"), 3)
    for obstacle in BLOCKS:
        if obstacle.size.y >= 170 or obstacle.size.x >= 500:
            draw_rect(obstacle, Color("#52606b"))
            draw_rect(obstacle.grow(-5), Color("#293b48"))
    # Clear passage between the two rooms.
    draw_rect(Rect2(718, 315, 36, 98), Color("#4f938f"))
    draw_line(Vector2(721, 316), Vector2(721, 411), Color("#9bf0d8"), 3)
    for light_pos in [Vector2(500, 240), Vector2(550, 525), Vector2(940, 360)]:
        _glow(light_pos, Color("#62dcc4"), 96)
        draw_circle(light_pos, 8, Color("#b2f9ea"))
    _marine(player, facing)
    if player.distance_to(LIFT_ENTRY) < 155:
        draw_arc(LIFT.get_center(), 78, 0, TAU, 40, Color("#8cfde1"), 3, true)
