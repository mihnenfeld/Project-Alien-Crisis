extends Node2D
## Demo 1.0: authored rendered command deck with 2D screen-space walk and masked foreground.
## This is a visual gameplay proof: the collision polygons are hand-matched approximations.
const WALK_SPEED := 150.0
const PLAYER_START := Vector2(730, 385)
var wall_floor: PackedVector2Array = PackedVector2Array([
    Vector2(130,350), Vector2(335,335), Vector2(480,315), Vector2(685,297),
    Vector2(980,292), Vector2(1225,416), Vector2(1225,631),
    Vector2(1080,670), Vector2(310,677), Vector2(90,531)
])
var blockers: Array[PackedVector2Array] = [
    PackedVector2Array([Vector2(215,245),Vector2(550,225),Vector2(565,379),Vector2(215,395)]),
    PackedVector2Array([Vector2(695,220),Vector2(918,220),Vector2(947,353),Vector2(686,356)]),
    PackedVector2Array([Vector2(415,375),Vector2(769,356),Vector2(898,548),Vector2(439,620)])
]
var player := PLAYER_START
var look_direction := Vector2(1, 0)
var stride := 0.0
var bg: Texture2D
var fg: Texture2D
var status: Label
var elapsed := 0.0

func _ready() -> void:
    bg = _load_png("res://assets/backgrounds/commanddeck_render_bg.png")
    fg = _load_png("res://assets/backgrounds/commanddeck_render_fg.png")
    RenderingServer.set_default_clear_color(Color("#050a0e"))
    var ui := CanvasLayer.new()
    add_child(ui)
    _label(ui, Vector2(25,18), "ALIEN CRISIS  /  KOMMANDODECK  /  RENDER-DEMO 1.0", 22, Color("#e8f3f2"))
    _label(ui, Vector2(28,52), "WASD LAUFEN  |  SHIFT SPRINTEN  |  E INTERAGIEREN  |  ESC BEENDEN", 14, Color("#adc3c7"))
    status = _label(ui, Vector2(28,682), "TEST: GERENDERTE KULISSE, LAUFZONEN UND VORDERGRUNDVERDECKUNG", 14, Color("#7be3cf"))
    if bg == null:
        status.text = "ASSET FEHLT: Alien_Crisis_Commanddeck_10.zip nach Downloads laden und .\\ac.ps1 render erneut starten."

func _load_png(path: String) -> Texture2D:
    if not FileAccess.file_exists(path):
        push_warning("Bild fehlt: "+path)
        return null
    var img := Image.new()
    var error := img.load(path)
    if error != OK:
        push_warning("Bild nicht lesbar: "+path)
        return null
    return ImageTexture.create_from_image(img)

func _label(root: Node, where: Vector2, text_value: String, size: int, color_value: Color) -> Label:
    var l := Label.new()
    l.position = where
    l.text = text_value
    l.add_theme_font_size_override("font_size",size)
    l.add_theme_color_override("font_color",color_value)
    root.add_child(l)
    return l

func _walkable(p: Vector2) -> bool:
    if not Geometry2D.is_point_in_polygon(p,wall_floor):
        return false
    for region in blockers:
        if Geometry2D.is_point_in_polygon(p,region):
            return false
    return true

func _physics_process(delta: float) -> void:
    elapsed += delta
    var axes := Input.get_vector("move_left","move_right","move_up","move_down")
    var speed := WALK_SPEED * (1.65 if Input.is_key_pressed(KEY_SHIFT) else 1.0)
    var offset := axes * speed * delta
    # Screen-space movement, stable even when future camera cuts are added.
    if _walkable(Vector2(player.x + offset.x, player.y)):
        player.x += offset.x
    if _walkable(Vector2(player.x,player.y + offset.y)):
        player.y += offset.y
    if axes.length_squared() > 0.01:
        look_direction = axes.normalized()
        stride += delta * (16.0 if Input.is_key_pressed(KEY_SHIFT) else 10.0)
    queue_redraw()

func _unhandled_key_input(ev: InputEvent) -> void:
    if not ev is InputEventKey or not ev.pressed or ev.echo:
        return
    if ev.keycode == KEY_ESCAPE:
        get_tree().quit()
    elif ev.keycode == KEY_E:
        if player.distance_to(Vector2(1020,375)) < 170:
            status.text = "A-17 / AUSGANG: IM TECHNIKTEST NOCH NICHT AKTIV"
        elif player.distance_to(Vector2(580,330)) < 160:
            status.text = "PAC / TERMINAL: FREIGABE AUSSTEHEND"
        else:
            status.text = "KEIN INTERAKTIONSPUNKT IN REICHWEITE"

func _draw() -> void:
    if bg != null:
        draw_texture_rect(bg,Rect2(Vector2.ZERO,Vector2(1280,720)),false)
    else:
        draw_rect(Rect2(0,0,1280,720),Color("#0a151c"))
    _player()
    # Front planning desk occludes the character only when behind its depth edge.
    if fg != null and player.y < 590:
        draw_texture_rect(fg,Rect2(Vector2.ZERO,Vector2(1280,720)),false)

func _player() -> void:
    var p := player
    draw_set_transform(p,0,Vector2(1.0,0.35))
    draw_circle(Vector2.ZERO,20.0,Color(0,0,0,0.55))
    draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
    var bob := sin(stride) * 2.2
    draw_rect(Rect2(p+Vector2(-11,-19+bob),Vector2(9,18)),Color("#243b45"))
    draw_rect(Rect2(p+Vector2(3,-19-bob),Vector2(9,18)),Color("#243b45"))
    draw_rect(Rect2(p+Vector2(-15,-54),Vector2(30,34)),Color("#748784"))
    draw_rect(Rect2(p+Vector2(-10,-48),Vector2(20,24)),Color("#355d63"))
    draw_circle(p+Vector2(0,-60),12.0,Color("#a2ada3"))
    draw_rect(Rect2(p+Vector2(-7,-62),Vector2(14,7)),Color("#367a83"))
    draw_line(p+Vector2(0,-37),p+Vector2(look_direction.x*24,-37+look_direction.y*12),Color("#a7c1b8"),6)
