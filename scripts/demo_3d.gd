extends Node3D
## Demo 0.9 – consistent physical 3D coordinates, perspective camera and collisions.
const SPEED := 3.6
var soldier: Node3D
var status: Label
var walk_clock := 0.0
var furniture: Array[Rect2] = [
    Rect2(0.5, 0.55, 2.5, 1.15),
    Rect2(5.35, 0.7, 1.15, 0.9),
    Rect2(3.65, 4.0, 2.1, 1.1)
]

func _ready() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#0a111a")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#6b8c9d")
    environment.ambient_light_energy = 0.48
    env.environment = environment
    add_child(env)
    var camera := Camera3D.new()
    camera.position = Vector3(10.0, 11.7, 15.0)
    camera.look_at_from_position(camera.position, Vector3(4.2, 0.65, 2.7), Vector3.UP)
    camera.fov = 48.0
    camera.current = true
    add_child(camera)
    _block("Boden", Vector3(4.1, -0.13, 2.75), Vector3(8.4, 0.25, 6.0), Color("#293a46"))
    _block("Rueckwand", Vector3(4.1, 1.7, -0.21), Vector3(8.5, 3.4, 0.32), Color("#3d5662"))
    _block("Rechte Wand", Vector3(8.37, 1.7, 2.75), Vector3(0.3, 3.4, 6.0), Color("#273d48"))
    for n in range(9):
        _block("Bodennaht", Vector3(0.5 + float(n) * 0.9, 0.01, 2.75), Vector3(0.015, 0.012, 5.85), Color("#54707c"))
    for n in range(7):
        _block("Quernaht", Vector3(4.1, 0.014, 0.35 + float(n) * 0.85), Vector3(8.25, 0.012, 0.015), Color("#54707c"))
    for n in range(8):
        _block("Wandstrebe", Vector3(0.35 + float(n) * 1.07, 1.74, -0.01), Vector3(0.07, 3.3, 0.09), Color("#66818a"))
    _block("Kommandotisch", Vector3(1.75, 0.6, 1.125), Vector3(2.5, 1.2, 1.15), Color("#425a63"))
    _block("Monitor Kommandotisch", Vector3(1.75, 1.215, 1.1), Vector3(1.68, 0.025, 0.6), Color("#155465"))
    _block("Terminal", Vector3(5.925, 0.52, 1.15), Vector3(1.15, 1.04, 0.9), Color("#405460"))
    _block("Bildschirm Terminal", Vector3(5.925, 1.05, 1.12), Vector3(0.77, 0.023, 0.5), Color("#14778a"))
    _block("Arbeitstisch", Vector3(4.7, 0.43, 4.55), Vector3(2.1, 0.86, 1.1), Color("#53616b"))
    _block("Markierung", Vector3(7.22, 0.015, 4.8), Vector3(0.8, 0.02, 0.6), Color("#a87c42"))
    for n in range(3):
        _block("Wandmonitor", Vector3(1.0 + float(n) * 2.2, 2.25, -0.015), Vector3(1.42, 0.76, 0.1), Color("#134554"))
        _block("Display", Vector3(1.0 + float(n) * 2.2, 2.25, 0.045), Vector3(1.16, 0.45, 0.04), Color("#298799"))
    soldier = Node3D.new()
    soldier.position = Vector3(3.25, 0.0, 3.1)
    add_child(soldier)
    _body_part("Beine", Vector3(0, 0.38, 0), Vector3(0.32, 0.75, 0.30), Color("#2c414a"))
    _body_part("Ruestung", Vector3(0, 1.06, 0), Vector3(0.72, 0.8, 0.48), Color("#728780"))
    _body_part("Brustplatte", Vector3(0, 1.12, 0.26), Vector3(0.49, 0.5, 0.1), Color("#365c61"))
    _body_part("Helm", Vector3(0, 1.73, 0), Vector3(0.52, 0.49, 0.52), Color("#a0b1a3"))
    _body_part("Visier", Vector3(0, 1.75, 0.27), Vector3(0.36, 0.19, 0.06), Color("#59ced6"))
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-50, -30, 0)
    sun.light_energy = 0.6
    add_child(sun)
    var lamp := OmniLight3D.new()
    lamp.position = Vector3(4.4, 2.9, 1.6)
    lamp.light_color = Color("#80cde2")
    lamp.light_energy = 1.0
    lamp.omni_range = 8.0
    add_child(lamp)
    var ui := CanvasLayer.new()
    add_child(ui)
    _label(ui, Vector2(32, 20), "ALIEN CRISIS / 3D-KOMMANDODECK / DEMO 0.9", 24, Color("#eef4f5"))
    _label(ui, Vector2(34, 59), "WASD BEWEGEN  |  SHIFT SPRINTEN  |  E INTERAGIEREN  |  ESC BEENDEN", 15, Color("#a8bcc6"))
    status = _label(ui, Vector2(35, 676), "ECHTE 3D-GEOMETRIE  /  PERSPEKTIVKAMERA  /  FESTER BILDAUSSCHNITT", 15, Color("#78e1d4"))

func _block(label_text: String, pos: Vector3, dims: Vector3, tint: Color) -> void:
    var mesh := MeshInstance3D.new()
    mesh.name = label_text
    var box_mesh := BoxMesh.new()
    box_mesh.size = dims
    mesh.mesh = box_mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.metallic = 0.28
    material.roughness = 0.65
    mesh.material_override = material
    mesh.position = pos
    add_child(mesh)

func _body_part(label_text: String, pos: Vector3, dims: Vector3, tint: Color) -> void:
    var mesh := MeshInstance3D.new()
    mesh.name = label_text
    var box_mesh := BoxMesh.new()
    box_mesh.size = dims
    mesh.mesh = box_mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.roughness = 0.82
    mesh.material_override = material
    mesh.position = pos
    soldier.add_child(mesh)

func _label(node: Node, pos: Vector2, value: String, size: int, tint: Color) -> Label:
    var l := Label.new()
    l.position = pos
    l.text = value
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", tint)
    node.add_child(l)
    return l

func _inside(p: Vector2) -> bool:
    if p.x < 0.35 or p.x > 7.88 or p.y < 0.35 or p.y > 5.55:
        return false
    for obstacle in furniture:
        if obstacle.grow(0.28).has_point(p):
            return false
    return true

func _physics_process(delta: float) -> void:
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var motion := input_dir * SPEED * (1.65 if Input.is_key_pressed(KEY_SHIFT) else 1.0) * delta
    var p := Vector2(soldier.position.x, soldier.position.z)
    if _inside(p + Vector2(motion.x, 0)):
        soldier.position.x += motion.x
    if _inside(Vector2(soldier.position.x, soldier.position.z + motion.y)):
        soldier.position.z += motion.y
    if input_dir.length() > 0.03:
        soldier.rotation.y = atan2(input_dir.x, input_dir.y)
        walk_clock += delta

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_ESCAPE:
        get_tree().quit()
    if event.keycode == KEY_E:
        var p := Vector2(soldier.position.x, soldier.position.z)
        if p.distance_to(Vector2(6.85, 4.9)) < 1.1:
            status.text = "AUSGANG A-17  /  3D-TESTRAUM – NOCH KEIN LEVELWECHSEL"
        elif p.distance_to(Vector2(4.5, 1.95)) < 1.5:
            status.text = "KOMMANDOTERMINAL  /  PAC-ZUGRIFF GESPERRT"
        else:
            status.text = "KEIN INTERAKTIONSZIEL IN REICHWEITE"
