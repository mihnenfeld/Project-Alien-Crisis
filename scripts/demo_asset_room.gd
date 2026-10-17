extends Node3D
## PAC asset-library test room. No primitive mesh stand-ins: all visible
## environment meshes are from the imported Quaternius glTF pack.
const CHARACTER = preload("res://scripts/ac_asset_character.gd")
const PACK := "res://assets/library/packs/quaternius_scifi_standard/glTF/"
var actor: CharacterBody3D
var hud: Label
var obstacles: Array[Rect2] = []
var built := 0
var camera: Camera3D
var camera_slot := -1

func _ready() -> void:
    _environment()
    _assemble()
    actor = CharacterBody3D.new()
    actor.set_script(CHARACTER)
    add_child(actor)
    actor.position = Vector3(4.25, 0, 4.8)
    actor.rotation.y = 0.0
    actor.set("can_stand", Callable(self, "_can_stand"))
    camera = Camera3D.new()
    add_child(camera)
    camera.fov = 45.0
    camera.current = true
    _set_camera(0)
    var ui := CanvasLayer.new()
    add_child(ui)
    hud = Label.new()
    hud.position = Vector2(24, 25)
    hud.add_theme_font_size_override("font_size", 22)
    hud.add_theme_color_override("font_color", Color("#b8e7e8"))
    ui.add_child(hud)
    if built == 0:
        hud.text = "PAC ASSETLIB: MODELLE FEHLEN | Installiere MegaKit mit tools/install-pac-assetlib.ps1"
        push_error("PAC AssetLib package missing: " + PACK)
    else:
        hud.text = "PAC / KOMMANDODECK   |   %d 3D-BAUTEILE   |   WASD / SHIFT / ESC" % built

func _environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#080e15")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#768c9a")
    env.ambient_light_energy = 0.43
    world.environment = env
    add_child(world)
    _lamp(Vector3(2.2, 2.9, 2.0), Color("#b8daea"), 2.1, 7.2)
    _lamp(Vector3(7.3, 2.7, 1.7), Color("#65a8c7"), 1.6, 6.0)
    _lamp(Vector3(8.0, 2.0, 5.8), Color("#e27344"), 1.3, 3.2)

func _lamp(at: Vector3, tint: Color, energy: float, reach: float) -> void:
    var node := OmniLight3D.new()
    node.position = at
    node.light_color = tint
    node.light_energy = energy
    node.omni_range = reach
    add_child(node)

func _asset(folder: String, name: String, at: Vector3, target: Vector3, angle: float = 0.0) -> void:
    var file := PACK + folder + "/" + name + ".gltf"
    if not ResourceLoader.exists(file):
        push_warning("Asset fehlt: " + file)
        return
    var packed: PackedScene = load(file) as PackedScene
    if packed == null:
        push_warning("Asset kann nicht geladen werden: " + file)
        return
    var model := packed.instantiate()
    model.name = name
    var placement := Node3D.new()
    placement.name = "Asset_%03d_%s" % [built + 1, name]
    add_child(placement)
    placement.position = at
    placement.rotation.y = deg_to_rad(angle)
    placement.add_child(model)
    # Normalize imported meshes by their actual bounding boxes, rather than
    # guessing whether this pack uses centimetres, metres, or another unit.
    var bounds := _bounds(model)
    if bounds.size.length() > 0.001:
        var size := bounds.size
        var ratios := Vector3(
            target.x / maxf(size.x, 0.001),
            target.y / maxf(size.y, 0.001),
            target.z / maxf(size.z, 0.001)
        )
        model.scale = ratios
        model.position = Vector3(-bounds.position.x * ratios.x - target.x * 0.5, -bounds.position.y * ratios.y, -bounds.position.z * ratios.z - target.z * 0.5)
    built += 1

func _bounds(root: Node) -> AABB:
    var found := false
    var combined := AABB()
    for item in root.find_children("*", "MeshInstance3D", true, false):
        var mesh_node := item as MeshInstance3D
        if mesh_node.mesh == null:
            continue
        var b := mesh_node.transform * mesh_node.get_aabb()
        if not found:
            combined = b
            found = true
        else:
            combined = combined.merge(b)
    return combined

func _assemble() -> void:
    # 9 x 7m industrial command / comms suite, grid-based,
    # viewed in real-time from a fixed cinematic camera.
    for ix in range(5):
        for iz in range(4):
            _asset("Platforms", "Platform_DarkPlates", Vector3(0.9 + ix * 1.8, -0.12, 0.875 + iz * 1.75), Vector3(1.8, 0.16, 1.75))
    # Quaternius wall segments run along their LOCAL Z axis, not local X.
    # Rear wall: rotate 90 degrees and give it length on local Z.
    # Side walls: leave unrotated. Prefer straight, flat wall panels;
    # Astra's projecting braces looked like leaning broken plates.
    for i in range(5):
        var x := 0.9 + float(i) * 1.8
        _asset("Walls", "WallAstra_Straight_Flat", Vector3(x, 0, 0.12), Vector3(0.20, 2.75, 1.8), 90.0)
        _asset("Walls", "TopCables_Straight", Vector3(x, 2.65, 0.30), Vector3(0.28, 0.55, 1.8), 90.0)
    for i in range(4):
        var z := 0.875 + float(i) * 1.75
        _asset("Walls", "WallBand_Straight", Vector3(0.12, 0, z), Vector3(0.20, 2.75, 1.75))
        _asset("Walls", "WallBand_Straight", Vector3(8.88, 0, z), Vector3(0.20, 2.75, 1.75), 180.0)
    # Camera-facing fourth wall intentionally omitted, as with a
    # classic survival-horror cutaway shot. The other three sides join.
    for x in [0.25, 4.5, 8.75]:
        _asset("Columns", "Column_MetalSupport", Vector3(x, 0, 0.25), Vector3(0.25, 2.8, 0.25))
    # Real computer, containers, service fan, lamps, and cable models.
    _asset("Props", "Prop_Computer", Vector3(2.1, 0, 1.45), Vector3(1.45, 1.45, 0.86))
    _asset("Props", "Prop_Computer", Vector3(6.65, 0, 1.45), Vector3(1.45, 1.45, 0.86))
    _asset("Props", "Prop_Crate3", Vector3(5.2, 0, 4.5), Vector3(1.3, 1.0, 1.3), 18)
    _asset("Props", "Prop_Crate4", Vector3(7.7, 0, 5.5), Vector3(1.1, 1.15, 1.1), -10)
    _asset("Props", "Prop_Barrel_Large", Vector3(7.75, 0, 4.2), Vector3(0.7, 1.2, 0.7))
    _asset("Props", "Prop_Vent_Wide", Vector3(4.5, 1.2, 0.5), Vector3(1.8, 1.1, 0.35))
    _asset("Props", "Prop_Cable_3", Vector3(3.9, 0.0, 0.85), Vector3(1.0, 0.25, 1.0))
    for x in [1.8, 4.5, 7.2]:
        _asset("Props", "Prop_Light_Wide", Vector3(x, 2.85, 1.5), Vector3(1.05, 0.18, 0.35))
    _asset("Props", "Prop_Light_Small", Vector3(8.45, 2.25, 6.1), Vector3(0.35, 0.35, 0.35))
    # Rear wall and both side walls are the continuous architectural shell.
    # Gameplay blockers remain simple and invisible; visual models are true assets.
    obstacles = [
        Rect2(1.25, 0.9, 1.65, 1.2),
        Rect2(5.8, 0.9, 1.7, 1.2),
        Rect2(4.45, 3.75, 1.55, 1.5),
        Rect2(7.0, 4.8, 1.35, 1.45),
        Rect2(7.2, 3.55, 1.0, 1.25)
    ]


func _process(_delta: float) -> void:
    if actor == null or camera == null:
        return
    # Two stable camera positions (no follow camera). The player remains
    # a single persistent actor; switch only when entering the rear zone.
    var desired := 1 if actor.position.z < 2.55 else 0
    if desired != camera_slot:
        _set_camera(desired)

func _set_camera(slot: int) -> void:
    camera_slot = slot
    if slot == 0:
        # South/front wall removed: soldier is viewed from the front.
        camera.position = Vector3(4.5, 4.1, 12.3)
        camera.look_at(Vector3(4.5, 1.05, 3.3), Vector3.UP)
    else:
        # Second fixed Dino Crisis-style diagonal establishing shot.
        camera.position = Vector3(7.3, 4.5, 11.7)
        camera.look_at(Vector3(4.6, 1.05, 2.65), Vector3.UP)

func _can_stand(point: Vector2, radius: float = 0.19) -> bool:
    if point.x < radius + 0.2 or point.x > 8.8 - radius or point.y < 0.35 + radius or point.y > 6.8 - radius:
        return false
    for rect in obstacles:
        if rect.grow(radius).has_point(point):
            return false
    return true

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
        get_tree().quit()
