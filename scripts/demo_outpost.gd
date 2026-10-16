extends Node2D
## Alien Crisis: standalone top-down environment/character vertical slice.
## All graphics are original procedural vector shapes; no third-party assets.
const FLOOR := Rect2(56, 98, 1168, 564)
const BLOCKS := [
    Rect2(56,98,1168,24), Rect2(56,638,1168,24),
    Rect2(56,98,24,564), Rect2(1200,98,24,564),
    Rect2(724,122,24,194), Rect2(724,412,24,226),
    Rect2(282,240,130,56), Rect2(982,462,124,55)
]
const SPEED := 230.0
const SPRINT_MULTIPLIER := 1.65
var ambience_time: float = 0.0
var player := Vector2(220, 447)
var facing := 0.0
var footsteps := 0.0
var gate_open := false
var gate_released := false
var generator_on := false
var announcement := "FUNKSIGNAL: AUSSENPOSTEN A-17 // SYSTEMCHECK"
var title_label: Label
var hint_label: Label
var status_label: Label
var console_rect := Rect2(852, 267, 78, 56)
var access_panel_rect := Rect2(600, 263, 66, 50)
var generator_rect := Rect2(402, 157, 82, 64)
var gate_rect := Rect2(720, 315, 32, 98)
var ui: CanvasLayer
var material_cache: Dictionary = {}

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color("#070c14"))
    ui = CanvasLayer.new()
    add_child(ui)
    title_label = _label(Vector2(38, 21), "ALIEN CRISIS   /   OUTPOST A-17", 26, Color("#e6f3f1"))
    hint_label = _label(Vector2(40, 60), "WASD BEWEGEN     |     MAUS ZIELEN     |     E INTERAGIEREN     |     ESC BEENDEN", 15, Color("#91a7b5"))
    status_label = _label(Vector2(45, 678), "", 17, Color("#79e8d8"))
    _update_status()

func _label(pos: Vector2, content: String, size: int, color: Color) -> Label:
    var label := Label.new()
    label.position = pos
    label.text = content
    label.add_theme_color_override("font_color", color)
    label.add_theme_font_size_override("font_size", size)
    ui.add_child(label)
    return label

func _physics_process(delta: float) -> void:
    var movement := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var running: bool = Input.is_key_pressed(KEY_SHIFT)
    var next := player + movement * SPEED * (SPRINT_MULTIPLIER if running else 1.0) * delta
    if not _blocked(Vector2(next.x, player.y)):
        player.x = next.x
    if not _blocked(Vector2(player.x, next.y)):
        player.y = next.y
    if movement.length() > 0.01:
        footsteps += delta * (18.0 if running else 11.0)
    ambience_time += delta
    facing = (get_global_mouse_position() - player).angle()
    queue_redraw()

func _blocked(test: Vector2) -> bool:
    if not FLOOR.grow(-28).has_point(test):
        return true
    for obstacle in BLOCKS:
        if obstacle.grow(16).has_point(test):
            return true
    if not gate_open and gate_rect.grow(16).has_point(test):
        return true
    if console_rect.grow(16).has_point(test) or generator_rect.grow(16).has_point(test) or access_panel_rect.grow(12).has_point(test):
        return true
    return false

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey:
        return
    if not event.pressed or event.echo:
        return
    if event.keycode == KEY_ESCAPE:
        get_tree().quit()
    if event.keycode == KEY_E:
        if player.distance_to(gate_rect.get_center()) < 110:
            if not generator_on:
                announcement = "SCHOTT VERRIEGELT: NOTSTROMVERSORGUNG FEHLT."
            elif not gate_released:
                announcement = "SCHOTT VERRIEGELT: FREIGABE AM TERMINAL ERFORDERLICH."
            elif gate_open:
                gate_open = false
                gate_released = false
                announcement = "SCHOTT MANUELL VERRIEGELT. NEUE TERMINALFREIGABE ERFORDERLICH."
            else:
                gate_open = true
                announcement = "SCHOTT GEÖFFNET."
        elif player.distance_to(access_panel_rect.get_center()) < 110 or player.distance_to(console_rect.get_center()) < 110:
            if not generator_on:
                announcement = "TERMINAL OFFLINE: GENERATOR AKTIVIEREN."
            elif gate_released:
                gate_released = false
                gate_open = false
                announcement = "SICHERHEITSVERRIEGELUNG AKTIVIERT."
            else:
                gate_released = true
                announcement = "SCHOTT FREIGEGEBEN. AM SCHOTT MIT E ÖFFNEN."
        elif player.distance_to(generator_rect.get_center()) < 110:
            generator_on = not generator_on
            if not generator_on:
                gate_open = false
                gate_released = false
            announcement = "GENERATOR ONLINE. SCHOTT AM TERMINAL FREIGEBEN." if generator_on else "GENERATOR OFFLINE. SCHOTT VERRIEGELT."
        else:
            announcement = "KEIN INTERAKTIVES OBJEKT IN REICHWEITE"
        _update_status()

func _update_status() -> void:
    status_label.text = announcement

func _material(name: String) -> Texture2D:
    if material_cache.has(name):
        return material_cache[name]
    var path := "res://assets/materials/pack01/%s/%s_albedo.png" % [name, name]
    var image := Image.new()
    var err := image.load(ProjectSettings.globalize_path(path))
    if err != OK:
        material_cache[name] = null
        return null
    var texture := ImageTexture.create_from_image(image)
    material_cache[name] = texture
    return texture

func _surface(name: String, area: Rect2, opacity: float = 0.85) -> void:
    var texture := _material(name)
    if texture != null:
        draw_texture_rect(texture, area, true, Color(1, 1, 1, opacity))

func _wall_depth(area: Rect2) -> void:
    draw_rect(Rect2(area.position + Vector2(7, 10), area.size), Color(0, 0, 0, 0.36))
    draw_rect(area, Color("#43515a"))
    _surface("wall", area.grow(-3), 0.86)
    draw_line(area.position + Vector2(2, 2), Vector2(area.end.x - 2, area.position.y + 2), Color("#a1bbc0"), 2)
    draw_line(Vector2(area.end.x - 2, area.position.y + 5), area.end - Vector2(2, 2), Color("#0e1720"), 4)

func _draw() -> void:
    draw_rect(FLOOR, Color("#101b27"))
    # Floor grid + visually differentiated wings.
    draw_rect(Rect2(80,122,644,516), Color("#172632"))
    draw_rect(Rect2(748,122,452,516), Color("#18252c"))
    for x in range(88,1200,32):
        draw_line(Vector2(x,122),Vector2(x,638),Color(0.23,0.40,0.45,0.11),1)
    for y in range(130,638,32):
        draw_line(Vector2(80,y),Vector2(1200,y),Color(0.23,0.40,0.45,0.11),1)
    _surface("floor", Rect2(80, 122, 644, 516), 0.49)
    _surface("floor", Rect2(748, 122, 452, 516), 0.49)
    _decorative_details()
    # Hazard stripes and floor markings.
    draw_rect(Rect2(685,314,34,100), Color("#b38330"))
    for y in range(314,415,16):
        draw_line(Vector2(686,y+12),Vector2(715,y),Color("#322c20"),5)
    draw_rect(Rect2(104,354,302,4),Color("#4e9b9d"))
    draw_rect(Rect2(104,361,302,2),Color("#33545a"))
    draw_rect(Rect2(809,435,280,3),Color("#8a9b6d"))
    # Furnishings, two industrial crates and workstations.
    _crate(Rect2(282,240,130,56))
    _crate(Rect2(982,462,124,55))
    _crate(Rect2(132,179,70,63))
    _crate(Rect2(1100,170,62,62))
    # Generator with indicator and small glow.
    _glow(generator_rect.get_center(), Color("#32d9b3") if generator_on else Color("#d78e45"), 90)
    draw_rect(generator_rect, Color("#30434a"))
    draw_rect(generator_rect.grow(-6), Color("#1b2e3a"))
    draw_rect(Rect2(419,175,47,19),Color("#42e5c0") if generator_on else Color("#b88a45"))
    for i in range(4):
        draw_rect(Rect2(412 + i*18,204,9,5),Color("#839ca1"))
    # West-side security panel: door can be authorized before entering east wing.
    draw_rect(access_panel_rect, Color("#293f4a"))
    draw_rect(access_panel_rect.grow(-7), Color("#124550") if generator_on else Color("#26333b"))
    draw_rect(Rect2(609,274,45,4), Color("#7af8d5") if gate_released else Color("#d89a5b"))
    draw_rect(Rect2(609,285,32,3), Color("#64a5a6"))
    # Eastern terminal and antenna.
    _glow(console_rect.get_center(),Color("#28cbbf"),76)
    draw_rect(console_rect,Color("#283a45"))
    draw_rect(console_rect.grow(-9),Color("#153f4b"))
    draw_line(Vector2(863,280),Vector2(916,280),Color("#56ded6"),2)
    draw_line(Vector2(863,287),Vector2(898,287),Color("#56ded6"),2)
    draw_line(Vector2(863,294),Vector2(908,294),Color("#56ded6"),2)
    # Door and structural walls.
    for obstacle in BLOCKS:
        _wall_depth(obstacle)
    if not gate_open:
        _surface("bulkhead", gate_rect.grow(10), 0.72)
        draw_rect(gate_rect,Color("#b47f3a"))
        draw_rect(gate_rect.grow(-7),Color("#66543e"))
        for y in range(325,408,13):
            draw_line(Vector2(730,y),Vector2(742,y),Color("#d1b16c"),2)
    else:
        draw_rect(Rect2(722,315,23,13),Color("#b47f3a"))
        draw_rect(Rect2(722,398,23,14),Color("#b47f3a"))
    # Lighting fixtures and light pools.
    for pos in [Vector2(225,324),Vector2(555,500),Vector2(1018,202)]:
        _glow(pos, Color("#55c8be"), 96)
        draw_circle(pos,9,Color("#c1f3db"))
        draw_circle(pos,5,Color.WHITE)
    _marine(player, facing)
    # Hover-style interaction marker.
    for target in [generator_rect.get_center(),console_rect.get_center(),access_panel_rect.get_center(),gate_rect.get_center()]:
        if player.distance_to(target)<110:
            draw_arc(target,31,0,TAU,40,Color("#7af8d5"),2,true)

func _decorative_details() -> void:
    # Bolts, grates, cable lines and slowly pulsing warning beacon.
    for x in range(130, 1150, 145):
        for y in range(182, 610, 130):
            draw_circle(Vector2(x, y), 2.5, Color("#61737d"))
            draw_line(Vector2(x - 17, y + 35), Vector2(x + 20, y + 35), Color("#101923"), 3)
    for i in range(6):
        var px: float = 152.0 + i * 169.0
        draw_rect(Rect2(px, 611, 56, 9), Color("#101a23"))
        for j in range(4):
            draw_line(Vector2(px + 7.0 + j * 13.0, 612), Vector2(px + 7.0 + j * 13.0, 619), Color("#70828a"), 2)
    var pulse: float = 0.38 + 0.25 * sin(ambience_time * 4.0)
    draw_circle(Vector2(716, 306), 20, Color(0.96, 0.28, 0.15, pulse * 0.20))
    draw_circle(Vector2(716, 306), 5, Color(1.0, 0.29, 0.16, pulse + 0.15))

func _raised_prop(area: Rect2, height_px: float, accent: Color) -> void:
    # The rear face is displaced upward while all collision remains on the original footprint.
    var top := Rect2(area.position - Vector2(0.0, height_px), area.size)
    draw_rect(Rect2(area.position + Vector2(10, 8), area.size), Color(0, 0, 0, 0.28))
    draw_colored_polygon(PackedVector2Array([
        top.position + Vector2(top.size.x, 0),
        top.end,
        area.end,
        area.position + Vector2(area.size.x, 0)
    ]), Color("#182731"))
    draw_rect(top, Color("#364b57"))
    draw_rect(top.grow(-6), Color("#172d38"))
    draw_rect(Rect2(top.position + Vector2(9, 8), Vector2(top.size.x - 18, 5)), accent)
    draw_line(top.position, top.position + Vector2(top.size.x, 0), Color("#96aeb3"), 2)

func _glow(pos:Vector2,color:Color,radius:int) -> void:
    for i in range(5,0,-1):
        draw_circle(pos,float(radius)*float(i)/5.0,Color(color.r,color.g,color.b,0.016))

func _crate(rect:Rect2) -> void:
    draw_rect(rect,Color("#0b131b"))
    draw_rect(rect.grow(-4),Color("#52606b"))
    draw_rect(rect.grow(-9),Color("#303c46"))
    draw_line(rect.position+Vector2(10,10),rect.end-Vector2(10,10),Color("#81949e"),3)
    draw_line(Vector2(rect.end.x-10,rect.position.y+10),Vector2(rect.position.x+10,rect.end.y-10),Color("#81949e"),3)

func _marine(pos:Vector2,angle:float) -> void:
    draw_circle(pos+Vector2(5,9),21,Color(0,0,0,0.36))
    draw_set_transform(pos,angle)
    # The original top-down soldier silhouette: boots, pack, armor, helmet, rifle.
    var stride := sin(footsteps)*3.0
    draw_rect(Rect2(-13,-17+stride,12,12),Color("#293e4e"))
    draw_rect(Rect2(-13,5-stride,12,12),Color("#293e4e"))
    draw_rect(Rect2(-14,-11,27,23),Color("#657c76"))
    draw_rect(Rect2(-10,-8,21,17),Color("#324f56"))
    draw_rect(Rect2(-15,-15,8,12),Color("#657d79"))
    draw_rect(Rect2(-15,6,8,12),Color("#657d79"))
    draw_circle(Vector2(4,0),12,Color("#9ea99a"))
    draw_circle(Vector2(8,0),8,Color("#516d70"))
    draw_rect(Rect2(4,-6,13,12),Color("#223840"))
    draw_rect(Rect2(11,-4,24,8),Color("#8da2a4"))
    draw_rect(Rect2(29,-2,17,4),Color("#151f29"))
    draw_circle(Vector2(8,0),3,Color("#6ff2e2"))
    draw_set_transform(Vector2.ZERO,0)
