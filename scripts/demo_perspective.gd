extends Node2D
## Standalone 2.5D projection study: independent walk-space, projected at an oblique angle.
## Geometry and characters use one shared projection; furniture occludes the marine by foot depth.
const SPEED: float = 245.0
const SPRINT: float = 1.65
const ROOM := Rect2(0, 0, 850, 610)
const FURNITURE := [
    {"area": Rect2(110, 90, 260, 110), "height": 95.0, "type": "command"},
    {"area": Rect2(580, 110, 150, 90), "height": 78.0, "type": "console"},
    {"area": Rect2(460, 405, 225, 95), "height": 42.0, "type": "crate"}
]
var feet := Vector2(320, 350)
var facing: float = 0.0
var time_passed: float = 0.0
var foot_cycle: float = 0.0
var label_status: Label

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color("#070d15"))
    var ui := CanvasLayer.new()
    add_child(ui)
    _label(ui, Vector2(35, 20), "ALIEN CRISIS  /  COMMAND DECK  /  2.5D STUDY 0.6", 24, Color("#e9eeee"))
    _label(ui, Vector2(37, 59), "WASD LAUFEN   |   SHIFT SPRINTEN   |   MAUS AUSRICHTEN   |   ESC BEENDEN", 15, Color("#91aab2"))
    label_status = _label(ui, Vector2(38, 674), "PERSPEKTIV-TEST  /  LAUFE VOR UND HINTER DIE EINRICHTUNG", 17, Color("#72e6d0"))

func _label(parent: Node, pos: Vector2, caption: String, size: int, tint: Color) -> Label:
    var l := Label.new()
    l.position = pos
    l.text = caption
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", tint)
    parent.add_child(l)
    return l

func _project(p: Vector2) -> Vector2:
    # Affine projection gives oblique floor and visible wall faces without any external artwork.
    return Vector2(220.0 + p.x * 0.90 + p.y * 0.30, 170.0 + p.y * 0.62 - p.x * 0.075)

func _physics_process(delta: float) -> void:
    time_passed += delta
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var next := feet + direction * SPEED * (SPRINT if Input.is_key_pressed(KEY_SHIFT) else 1.0) * delta
    next.x = clampf(next.x, 45.0, 805.0)
    next.y = clampf(next.y, 54.0, 565.0)
    if not _is_obstructed(Vector2(next.x, feet.y)):
        feet.x = next.x
    if not _is_obstructed(Vector2(feet.x, next.y)):
        feet.y = next.y
    if direction.length() > 0.05:
        foot_cycle += delta * (17.0 if Input.is_key_pressed(KEY_SHIFT) else 10.0)
    facing = (get_global_mouse_position() - _project(feet)).angle()
    queue_redraw()

func _is_obstructed(p: Vector2) -> bool:
    for obj in FURNITURE:
        var area: Rect2 = obj["area"]
        if area.grow(15).has_point(p):
            return true
    return false

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
        get_tree().quit()

func _polygon(points: Array[Vector2], tint: Color) -> void:
    draw_colored_polygon(PackedVector2Array(points), tint)

func _slab(area: Rect2, elevation: float, top_color: Color, front_color: Color) -> void:
    var a := _project(area.position)
    var b := _project(Vector2(area.end.x, area.position.y))
    var c := _project(area.end)
    var d := _project(Vector2(area.position.x, area.end.y))
    var shift := Vector2(0, -elevation)
    _polygon([d, c, c + shift, d + shift], front_color)
    _polygon([b, c, c + shift, b + shift], front_color.darkened(0.24))
    _polygon([a + shift, b + shift, c + shift, d + shift], top_color)
    draw_polyline(PackedVector2Array([a + shift, b + shift, c + shift, d + shift, a + shift]), Color("#6e8790"), 2.0)

func _draw() -> void:
    # The floor grid makes the oblique perspective explicit.
    _slab(ROOM, 0.0, Color("#263743"), Color("#101923"))
    for xx in range(0, 851, 85):
        draw_line(_project(Vector2(xx, 0)), _project(Vector2(xx, 610)), Color(0.48, 0.65, 0.67, 0.16), 1.0)
    for yy in range(0, 611, 61):
        draw_line(_project(Vector2(0, yy)), _project(Vector2(850, yy)), Color(0.48, 0.65, 0.67, 0.16), 1.0)
    # Back wall facades rise vertically from the far edge.
    var rear_l := _project(Vector2(0, 0))
    var rear_r := _project(Vector2(850, 0))
    _polygon([rear_l, rear_r, rear_r + Vector2(0, -132), rear_l + Vector2(0, -132)], Color("#394c59"))
    for x in range(40, 850, 115):
        var p := _project(Vector2(x, 0))
        draw_line(p, p + Vector2(0, -132), Color("#69818a"), 3.0)
    for bar in [Vector2(225, -101), Vector2(630, -101)]:
        var lamp_pos := _project(Vector2(bar.x, 0)) + Vector2(0, bar.y)
        _light(lamp_pos, Color("#63b9db"))
    # Side wall ends at floor boundary.
    var far := _project(Vector2(850, 0))
    var near := _project(Vector2(850, 610))
    _polygon([far, near, near + Vector2(0, -85), far + Vector2(0, -132)], Color("#23343d"))
    for i in range(3):
        var loc := _project(Vector2(850, float(i) * 200.0))
        draw_line(loc, loc + Vector2(0, -98), Color("#576875"), 3)
    # Rear wall industrial monitors.
    for x in [150.0, 420.0, 665.0]:
        var screen := _project(Vector2(x, 0)) + Vector2(0, -86)
        draw_rect(Rect2(screen - Vector2(44, 22), Vector2(88, 45)), Color("#122c38"))
        draw_rect(Rect2(screen - Vector2(37, 15), Vector2(74, 27)), Color("#174c59"))
        draw_line(screen + Vector2(-30, -6), screen + Vector2(23, -6), Color("#5cd6e0"), 2)
    # Raised furniture occludes characters only if the feet are behind its far edge.
    var objects_before: Array[Dictionary] = []
    var objects_after: Array[Dictionary] = []
    for item in FURNITURE:
        var r: Rect2 = item["area"]
        if feet.y < r.end.y:
            objects_after.append(item)
        else:
            objects_before.append(item)
    for item in objects_before:
        _furniture(item)
    _marine_25d()
    for item in objects_after:
        _furniture(item)
    # Dynamic beacon and atmospheric light.
    _light(_project(Vector2(760, 475)) + Vector2(0, -12), Color("#e88c4e"))
    var p := _project(Vector2(760, 475))
    draw_arc(p, 25, 0, TAU, 32, Color("#dd905b"), 2.5)

func _furniture(obj: Dictionary) -> void:
    var r: Rect2 = obj["area"]
    var h: float = obj["height"]
    var kind: String = obj["type"]
    _slab(r, h, Color("#425762"), Color("#172630"))
    var p := _project(r.position + r.size / 2.0) + Vector2(0, -h)
    if kind == "command":
        draw_rect(Rect2(p - Vector2(56, 19), Vector2(112, 38)), Color("#0d3745"))
        draw_line(p - Vector2(43, 6), p + Vector2(40, -6), Color("#61dce1"), 4)
        draw_line(p - Vector2(43, 7), p + Vector2(17, 7), Color("#4c96a4"), 3)
    elif kind == "console":
        draw_rect(Rect2(p - Vector2(28, 20), Vector2(56, 40)), Color("#0f3945"))
        draw_line(p + Vector2(-19, -5), p + Vector2(19, -5), Color("#c2a76e"), 4)
    else:
        for i in range(3):
            draw_line(p + Vector2(-46, -14 + i * 13), p + Vector2(38, -14 + i * 13), Color("#8e7656"), 3)

func _light(p: Vector2, tint: Color) -> void:
    var pulse := 0.85 + 0.15 * sin(time_passed * 2.4)
    for r in range(4, 0, -1):
        draw_circle(p, float(r) * 21.0, Color(tint.r, tint.g, tint.b, 0.014 * pulse))
    draw_circle(p, 5, tint)

func _marine_25d() -> void:
    var p := _project(feet)
    draw_ellipse_shadow(p)
    var bob := sin(foot_cycle) * 2.0
    draw_rect(Rect2(p + Vector2(-8, -20 + bob), Vector2(7, 17)), Color("#314954"))
    draw_rect(Rect2(p + Vector2(3, -20 - bob), Vector2(7, 17)), Color("#314954"))
    draw_rect(Rect2(p + Vector2(-13, -45), Vector2(26, 26)), Color("#647e7a"))
    draw_rect(Rect2(p + Vector2(-9, -42), Vector2(18, 20)), Color("#3c5b5e"))
    draw_circle(p + Vector2(0, -49), 11.0, Color("#91a69b"))
    draw_circle(p + Vector2(0, -49), 7.0, Color("#314f56"))
    draw_line(p + Vector2(0, -35), p + Vector2(30 * cos(facing), -35 + 30 * sin(facing)), Color("#91afae"), 7.0)
    draw_circle(p + Vector2(0, -49), 3.0, Color("#7cece4"))

func draw_ellipse_shadow(p: Vector2) -> void:
    draw_set_transform(p, 0, Vector2(1.0, 0.35))
    draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 0.46))
    draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
