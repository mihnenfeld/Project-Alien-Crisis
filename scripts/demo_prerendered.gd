extends Node2D
## Demo 0.8: layered authored background, independent character, navigation mask and foreground occlusion.
const SPEED: float = 190.0
const FLOOR_POLY := PackedVector2Array([Vector2(160,253),Vector2(850,211),Vector2(1092,557),Vector2(371,634)])
const OBSTACLES := [
    PackedVector2Array([Vector2(370,264),Vector2(560,250),Vector2(630,399),Vector2(400,415)]),
    PackedVector2Array([Vector2(737,292),Vector2(863,283),Vector2(909,421),Vector2(766,428)]),
    PackedVector2Array([Vector2(648,452),Vector2(842,439),Vector2(903,578),Vector2(677,599)])
]
const TERMINAL := Vector2(623, 296)
const DOOR := Vector2(988, 475)
var player: Vector2 = Vector2(575, 468)
var facing: float = 0.0
var walk_clock: float = 0.0
var popup: Label
var hovering := false
var background_texture: Texture2D
var foreground_texture: Texture2D

func _ready() -> void:
    background_texture = load("res://assets/backgrounds/commanddeck_bg.svg")
    foreground_texture = load("res://assets/backgrounds/commanddeck_fg.svg")
    RenderingServer.set_default_clear_color(Color("#060c14"))
    var canvas := CanvasLayer.new()
    add_child(canvas)
    _label(canvas, Vector2(31, 18), "ALIEN CRISIS  /  KOMMANDODECK  /  DEMO 0.8", 24, Color("#f0f6f3"))
    _label(canvas, Vector2(33, 56), "WASD BEWEGEN   |   SHIFT SPRINTEN   |   E INTERAGIEREN   |   ESC BEENDEN", 14, Color("#9ab3bc"))
    popup = _label(canvas, Vector2(35, 680), "PRERENDER-TECHNIKTEST  /  RAUM + SPIELFIGUR + LAUFMASKE", 15, Color("#82ead7"))
    queue_redraw()

func _label(node: Node, pos: Vector2, title: String, size: int, tint: Color) -> Label:
    var l := Label.new()
    l.position = pos
    l.text = title
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", tint)
    node.add_child(l)
    return l

func _can_walk(p: Vector2) -> bool:
    if not Geometry2D.is_point_in_polygon(p, FLOOR_POLY):
        return false
    for shape in OBSTACLES:
        if Geometry2D.is_point_in_polygon(p, shape):
            return false
    return true

func _physics_process(delta: float) -> void:
    var d := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var speed: float = SPEED * (1.65 if Input.is_key_pressed(KEY_SHIFT) else 1.0)
    var displacement := Vector2(d.x * 0.94 + d.y * 0.17, d.y * 0.72 - d.x * 0.07) * speed * delta
    var tentative := player + displacement
    if _can_walk(Vector2(tentative.x, player.y)):
        player.x = tentative.x
    if _can_walk(Vector2(player.x, tentative.y)):
        player.y = tentative.y
    if d.length() > 0.01:
        walk_clock += delta * (16.0 if Input.is_key_pressed(KEY_SHIFT) else 10.0)
    facing = (get_global_mouse_position() - player).angle()
    queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_ESCAPE:
        get_tree().quit()
    elif event.keycode == KEY_E:
        if player.distance_to(TERMINAL) < 105:
            popup.text = "TERMINAL: PAC-DATENARCHIV GESPERRT / FREIGABE AUSSTEHEND"
        elif player.distance_to(DOOR) < 115:
            popup.text = "AUSGANG A-17: IN DIESEM PERSPEKTIV-TEST NOCH OHNE LEVELWECHSEL"
        else:
            popup.text = "KEIN INTERAKTIVES OBJEKT IN REICHWEITE"

func _draw() -> void:
    if background_texture != null:
        draw_texture(background_texture, Vector2.ZERO)
    # Character is independent of the authored scenery.
    _marine()
    # Foreground furniture becomes an occluder only behind its screen-space depth plane.
    if player.y < 515.0 and foreground_texture != null:
        draw_texture(foreground_texture, Vector2.ZERO)
    if player.distance_to(TERMINAL) < 105:
        draw_arc(TERMINAL, 24, 0, TAU, 36, Color("#79e6d5"), 2, true)
    if player.distance_to(DOOR) < 115:
        draw_arc(DOOR, 30, 0, TAU, 36, Color("#deb16b"), 2, true)

func _marine() -> void:
    var p := player
    draw_set_transform(p + Vector2(2, 0), 0, Vector2(1.0, 0.36))
    draw_circle(Vector2.ZERO, 18, Color(0, 0, 0, 0.55))
    draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
    var stride: float = sin(walk_clock) * 3.5
    draw_rect(Rect2(p + Vector2(-10, -20 + stride), Vector2(8, 18)), Color("#263742"))
    draw_rect(Rect2(p + Vector2(3, -20 - stride), Vector2(8, 18)), Color("#263742"))
    draw_rect(Rect2(p + Vector2(-15, -51), Vector2(30, 34)), Color("#637974"))
    draw_rect(Rect2(p + Vector2(-10, -47), Vector2(20, 24)), Color("#2d4b53"))
    draw_circle(p + Vector2(0, -56), 12, Color("#889c94"))
    draw_circle(p + Vector2(0, -57), 8, Color("#345866"))
    draw_line(p + Vector2(0, -36), p + Vector2(cos(facing) * 29, -36 + sin(facing) * 29), Color("#acc5bd"), 7)
    draw_circle(p + Vector2(2, -57), 3, Color("#6de4e2"))
