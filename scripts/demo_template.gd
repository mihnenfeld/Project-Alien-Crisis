extends Node3D
## Demo 2.2: persistent connected world. Only camera changes, actor never respawns.
const ROOM_SCRIPT = preload("res://scripts/ac_room.gd")
const CHARACTER_SCRIPT = preload("res://scripts/ac_character.gd")
const ROOM_WIDTH := 9.0
var rooms: Array[Node3D] = []
var actor: CharacterBody3D
var heading: Label
var message: Label
var camera: Camera3D
var camera_slot := -1
var last_change := -100.0
var clock := 0.0

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
    heading = _label(ui,Vector2(26,21),"ALIEN CRISIS / VERBUNDENE RAUMWELT 2.2",24)
    _label(ui,Vector2(27,56),"WASD / SHIFT | KAMERA AUTOMATISCH | F5: KAMERATEST | ESC: ENDE",15)
    message = _label(ui,Vector2(28,682),"BEIDE RAEUME BESTEHEN DAUERHAFT. DURCHGANG RECHTS HINTEN.",15)
    _update_camera(true)

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
    heading.text = "ALIEN CRISIS / %s / DEMO 2.2" % ("WARTUNGSKORRIDOR" if camera_slot == 2 else "KOMMANDODECK")
    message.text = "KAMERA %d / POSITION X %.1f Z %.1f / KEIN RESPAWN" % [camera_slot+1,actor.position.x,actor.position.z]

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_ESCAPE:
        get_tree().quit()
    elif event.keycode == KEY_F5:
        message.text = "F5: RAUM WECHSELT NICHT MEHR. LAUFE DURCH DIE OEFFNUNG BEI X=9, Z=5."
