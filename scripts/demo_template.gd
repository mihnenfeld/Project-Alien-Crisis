extends Node3D
## Demo 2.2: persistent connected world. Only camera changes, actor never respawns.
const ROOM_SCRIPT = preload("res://scripts/ac_room.gd")
const CHARACTER_SCRIPT = preload("res://scripts/ac_character.gd")
const COMMAND_DETAILS = preload("res://scripts/ac_commanddeck_details.gd")
const ROOM_WIDTH := 9.0
var rooms: Array[Node3D] = []
var actor: CharacterBody3D
var heading: Label
var message: Label
var camera: Camera3D
var camera_slot := -1
var last_change := -100.0
var clock := 0.0
var baked_views: Dictionary = {}
var render_mode := false
var backdrop: MeshInstance3D
var baking := false
var view_label: Label
var capture_preview: TextureRect
var preview_visible := false
var concept_mode := false
var concept_texture: Texture2D
const CONCEPT_PATH := "res://assets/backgrounds/commanddeck_concept.png"

func _ready() -> void:
    var env := WorldEnvironment.new()
    var settings := Environment.new()
    settings.background_mode = Environment.BG_COLOR
    settings.background_color = Color("#090f18")
    settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    settings.ambient_light_color = Color("#adc4d2")
    settings.ambient_light_energy = 0.55
    env.environment = settings
    add_child(env)
    var lamp := DirectionalLight3D.new()
    lamp.rotation_degrees = Vector3(-55,-30,0)
    lamp.light_energy = 1.1
    add_child(lamp)
    _make_room(0)
    _make_room(1)
    actor = CharacterBody3D.new()
    actor.set_script(CHARACTER_SCRIPT)
    add_child(actor)
    actor.position = Vector3(4.3,0,3.4)
    actor.set("can_stand",Callable(self,"_can_stand"))
    camera = Camera3D.new()
    camera.fov = 51
    camera.current = true
    add_child(camera)
    var ui := CanvasLayer.new()
    add_child(ui)
    heading = _label(ui,Vector2(26,21),"ALIEN CRISIS / KOMMANDODECK 2.4",24)
    _label(ui,Vector2(27,56),"WASD / SHIFT | KAMERA AUTOMATISCH | F6: RENDER/3D | F7: VORSCHAU | F8: KONZEPT | F9: REFERENZ | ESC: ENDE",15)
    message = _label(ui,Vector2(28,682),"BEIDE RAEUME BESTEHEN DAUERHAFT. DURCHGANG RECHTS HINTEN.",15)
    view_label = _label(ui,Vector2(27,87),"F6: RENDERBILD EIN/AUS  |  ERSTER TEST: 3D-SZENE ALS EXAKTE KULISSE",14)
    capture_preview = TextureRect.new()
    capture_preview.position = Vector2(850, 96)
    capture_preview.size = Vector2(405, 228)
    capture_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    capture_preview.stretch_mode = TextureRect.STRETCH_SCALE
    capture_preview.visible = false
    ui.add_child(capture_preview)
    concept_texture = _load_concept()
    _update_camera(true)
    _prepare_backdrop()
    _bake_camera_views.call_deferred()

func _label(root: Node,pos: Vector2,value: String,size: int) -> Label:
    var label_node := Label.new()
    label_node.position = pos
    label_node.text = value
    label_node.add_theme_font_size_override("font_size",size)
    label_node.add_theme_color_override("font_color",Color("#c9efef"))
    root.add_child(label_node)
    return label_node

func _make_room(index: int) -> void:
    var room := Node3D.new()
    room.set_script(ROOM_SCRIPT)
    room.set("passage_right",index == 0)
    room.set("room_title","KOMMANDODECK" if index == 0 else "WARTUNG")
    room.position.x = float(index) * ROOM_WIDTH
    add_child(room)
    rooms.append(room)
    if index == 0:
        room.call("add_furniture","Command desk",Vector2(2.2,1.75),Vector2(2.6,1.1),1.15,Color("#536d79"))
        room.call("add_furniture","Terminal",Vector2(6.5,1.9),Vector2(1.25,1.0),1.05,Color("#315b65"))
        room.call("add_furniture","Planning table",Vector2(4.55,4.75),Vector2(2.5,1.25),0.85,Color("#5b6674"))
        var dressing := Node3D.new()
        dressing.name = "CommandDeckArt"
        dressing.set_script(COMMAND_DETAILS)
        room.add_child(dressing)
    else:
        room.call("add_furniture","Equipment",Vector2(1.6,1.4),Vector2(1.4,1.25),1.4,Color("#59616b"))
        room.call("add_furniture","Service panel",Vector2(7.3,1.4),Vector2(1.2,1.1),1.6,Color("#375365"))
        room.call("add_furniture","Cargo",Vector2(2.1,5.6),Vector2(1.5,1.0),0.8,Color("#776952"))

func _can_stand(global_point: Vector2, radius: float=0.19) -> bool:
    var x := global_point.x
    var z := global_point.y
    if x < radius or x > 18.0-radius or z < radius or z > 7.0-radius:
        return false
    # Continuous opening in the shared wall; furniture remains checked in local coordinates.
    if absf(x - ROOM_WIDTH) < radius+0.13 and (z < 4.0+radius or z > 6.0-radius):
        return false
    var index := 0 if x < ROOM_WIDTH else 1
    var local_point := Vector2(x - float(index)*ROOM_WIDTH,z)
    var node := rooms[index]
    var blockers: Array = node.get("obstacles")
    for rect in blockers:
        var obstacle: Rect2 = rect
        if obstacle.grow(radius).has_point(local_point):
            return false
    return true

func _process(delta: float) -> void:
    clock += delta
    if not baking:
        _update_camera(false)

func _update_camera(force: bool) -> void:
    if actor == null or camera == null:
        return
    var next_slot := 0
    if actor.position.x >= ROOM_WIDTH:
        next_slot = 2
    elif actor.position.z > 4.5:
        next_slot = 1
    if not force and next_slot == camera_slot:
        return
    if not force and clock - last_change < 0.3:
        return
    camera_slot = next_slot
    last_change = clock
    match camera_slot:
        0:
            camera.position = Vector3(11.3,7.7,11.5)
            camera.look_at(Vector3(4.5,0.9,3.3),Vector3.UP)
        1:
            camera.position = Vector3(0.6,6.7,10.6)
            camera.look_at(Vector3(4.5,0.9,3.5),Vector3.UP)
        2:
            camera.position = Vector3(22.8,8.8,12.4)
            camera.look_at(Vector3(13.5,0.9,3.3),Vector3.UP)
    heading.text = "ALIEN CRISIS / %s / DEMO 2.4" % ("WARTUNGSKORRIDOR" if camera_slot == 2 else "KOMMANDODECK")
    message.text = "KAMERA %d / POSITION X %.1f Z %.1f / KEIN RESPAWN" % [camera_slot+1,actor.position.x,actor.position.z]
    if concept_mode:
        _apply_concept()
    elif render_mode:
        _show_baked_view()
    _update_preview()

func _prepare_backdrop() -> void:
    backdrop = MeshInstance3D.new()
    backdrop.name = "CameraMatchedRender"
    var plane := QuadMesh.new()
    plane.size = Vector2(1, 1)
    backdrop.mesh = plane
    backdrop.visible = false
    add_child(backdrop)

func _camera_pose(slot: int) -> Transform3D:
    var p := Vector3(11.3,7.7,11.5)
    var target := Vector3(4.5,0.9,3.3)
    match slot:
        1:
            p = Vector3(0.6,6.7,10.6)
            target = Vector3(4.5,0.9,3.5)
        2:
            p = Vector3(22.8,8.8,12.4)
            target = Vector3(13.5,0.9,3.3)
    var c := Camera3D.new()
    add_child(c)
    c.position = p
    c.look_at(target,Vector3.UP)
    var result := c.global_transform
    c.queue_free()
    return result

func _bake_camera_views() -> void:
    if baking:
        return
    baking = true
    var ui: CanvasLayer = heading.get_parent() as CanvasLayer
    var original_pose := camera.global_transform
    actor.visible = false
    ui.visible = false
    backdrop.visible = false
    for room_node in rooms:
        room_node.visible = true
    # Capture the actual game viewport. This is the same working camera/world
    # the player sees, avoiding a secondary viewport with an empty world.
    for slot in range(3):
        camera.global_transform = _camera_pose(slot)
        await get_tree().process_frame
        await RenderingServer.frame_post_draw
        await RenderingServer.frame_post_draw
        var snapshot := get_viewport().get_texture().get_image()
        if snapshot != null and not snapshot.is_empty() and _has_rendered_content(snapshot):
            baked_views[slot] = ImageTexture.create_from_image(snapshot)
        else:
            push_warning("Kamera %d: Hauptviewport-Capture leer." % (slot + 1))
    camera.global_transform = original_pose
    actor.visible = true
    ui.visible = true
    baking = false
    view_label.text = "F6: RENDERBILD EIN/AUS | %d/3 KAMERABILDER" % baked_views.size()
    _update_preview()
    if render_mode:
        _show_baked_view()

func _update_preview() -> void:
    if capture_preview == null:
        return
    capture_preview.texture = baked_views.get(camera_slot, null)
    capture_preview.visible = preview_visible and capture_preview.texture != null

func _has_rendered_content(image: Image) -> bool:
    var different := 0
    var first := image.get_pixel(50, 50)
    for yy in range(80, image.get_height()-80, 95):
        for xx in range(80, image.get_width()-80, 95):
            var pixel := image.get_pixel(xx, yy)
            if absf(pixel.r-first.r) + absf(pixel.g-first.g) + absf(pixel.b-first.b) > 0.14:
                different += 1
                if different >= 3:
                    return true
    return false

func _show_baked_view() -> void:
    if backdrop == null or not baked_views.has(camera_slot):
        backdrop.visible = false
        return
    var tex: Texture2D = baked_views[camera_slot]
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_texture = tex
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    backdrop.material_override = mat
    var depth := 35.0
    var height := 2.0 * depth * tan(deg_to_rad(camera.fov) * 0.5)
    var aspect := 1280.0 / 720.0
    var quad: QuadMesh = backdrop.mesh
    quad.size = Vector2(height * aspect,height)
    backdrop.global_transform = camera.global_transform.translated_local(Vector3(0,0,-depth))
    backdrop.visible = true

func _toggle_render() -> void:
    if baking:
        view_label.text = "RENDER WIRD NOCH ERZEUGT ..."
        return
    render_mode = not render_mode
    for room_node in rooms:
        room_node.visible = not render_mode
    if render_mode:
        if baked_views.has(camera_slot):
            _show_baked_view()
        else:
            render_mode = false
            for room_node in rooms:
                room_node.visible = true
            view_label.text = "KEIN RENDERBILD VORHANDEN"
    else:
        backdrop.visible = false
    if baked_views.size() > 0:
        view_label.text = "F6: %s | %d/3 KAMERABILDER | FIGUR LIVE" % [("PRERENDER" if render_mode else "3D"), baked_views.size()]

func _load_concept() -> Texture2D:
    if not FileAccess.file_exists(CONCEPT_PATH):
        return null
    var image := Image.new()
    if image.load(CONCEPT_PATH) != OK:
        push_warning("Konzeptbild kann nicht geladen werden")
        return null
    return ImageTexture.create_from_image(image)

func _apply_concept() -> void:
    # Single-camera visual experiment; not a calibrated prerender yet.
    for r in rooms:
        r.visible = not concept_mode
    if not concept_mode:
        backdrop.visible = false
        return
    if concept_texture == null or camera_slot != 0:
        concept_mode = false
        for r in rooms:
            r.visible = true
        backdrop.visible = false
        view_label.text = "KONZEPT NUR KAMERA 1; F8 ERNEUT TESTEN"
        return
    _display_texture(concept_texture)
    view_label.text = "KONZEPTGRAFIK – NOCH NICHT PERSPEKTIVISCH REGISTRIERT"

func _display_texture(tex: Texture2D) -> void:
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_texture = tex
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    backdrop.material_override = mat
    var distance := 35.0
    var h := 2.0 * distance * tan(deg_to_rad(camera.fov)*0.5)
    var aspect := get_viewport().get_visible_rect().size.aspect()
    var quad: QuadMesh = backdrop.mesh
    quad.size = Vector2(h*aspect,h)
    backdrop.global_transform = camera.global_transform.translated_local(Vector3(0,0,-distance))
    backdrop.visible = true

func _export_camera_reference() -> void:
    if baking:
        return
    var was_concept := concept_mode
    var was_render := render_mode
    concept_mode = false
    render_mode = false
    backdrop.visible = false
    for r in rooms:
        r.visible = true
    var old_actor := actor.visible
    var ui_layer: CanvasLayer = heading.get_parent() as CanvasLayer
    var old_ui: bool = ui_layer.visible
    actor.visible = false
    ui_layer.visible = false
    await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var img := get_viewport().get_texture().get_image()
    var path := "user://alien_crisis_camera_%02d_reference.png" % (camera_slot + 1)
    var err := img.save_png(path)
    actor.visible = old_actor
    ui_layer.visible = old_ui
    concept_mode = was_concept
    render_mode = was_render
    if concept_mode:
        _apply_concept()
    elif render_mode:
        for r in rooms:
            r.visible = false
        _show_baked_view()
    view_label.text = ("REFERENZ GESPEICHERT: " + ProjectSettings.globalize_path(path)) if err == OK else ("EXPORTFEHLER: " + error_string(err))
    print(view_label.text)

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_ESCAPE:
        get_tree().quit()
    elif event.keycode == KEY_F8:
        if render_mode:
            _toggle_render()
        concept_mode = not concept_mode
        _apply_concept()
    elif event.keycode == KEY_F9:
        _export_camera_reference()
    elif event.keycode == KEY_F6:
        if concept_mode:
            concept_mode = false
            _apply_concept()
        _toggle_render()
    elif event.keycode == KEY_F7:
        preview_visible = not preview_visible
        _update_preview()
        view_label.text = "F7 VORSCHAU %s / BILD %d" % ["AN" if preview_visible else "AUS", camera_slot + 1]
    elif event.keycode == KEY_F5:
        message.text = "F5: RAUM WECHSELT NICHT MEHR. LAUFE DURCH DIE OEFFNUNG BEI X=9, Z=5."
