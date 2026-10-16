extends Node3D
## Demo 2.0. ONE reusable Room + Character script, TWO distinct layouts and fixed cameras.
var room: Node3D
var actor: CharacterBody3D
var active_room := 0
var heading: Label
var message: Label
var camera: Camera3D
const ROOM_SCRIPT = preload("res://scripts/ac_room.gd")
const CHARACTER_SCRIPT = preload("res://scripts/ac_character.gd")
func _ready() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color("#090f18")
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color("#adc4d2")
    e.ambient_light_energy = 0.55
    env.environment = e
    add_child(env)
    camera = Camera3D.new()
    camera.fov = 50
    camera.current = true
    add_child(camera)
    var lamp := DirectionalLight3D.new()
    lamp.rotation_degrees = Vector3(-55,-30,0)
    lamp.light_energy = 1.1
    add_child(lamp)
    actor = CharacterBody3D.new()
    actor.set_script(CHARACTER_SCRIPT)
    add_child(actor)
    var ui := CanvasLayer.new()
    add_child(ui)
    heading = _label(ui,Vector2(26,21),"ALIEN CRISIS / RAUM-TEMPLATE 2.0",24)
    _label(ui,Vector2(27,56),"WASD / SHIFT  |  E: TUER  |  F5: RAUM WECHSELN  |  ESC: ENDE",15)
    message = _label(ui,Vector2(28,682),"ECHTE 3D-GEOMETRIE: KOLLISION UND BILD IM SELBEN RAUM",15)
    _build_room(0)
func _label(root: Node,pos: Vector2,c: String,size: int) -> Label:
    var l := Label.new()
    l.position = pos
    l.text = c
    l.add_theme_font_size_override("font_size",size)
    l.add_theme_color_override("font_color",Color("#c9efef"))
    root.add_child(l)
    return l
func _build_room(index: int) -> void:
    if room != null:
        room.queue_free()
    active_room = index
    room = Node3D.new()
    room.set_script(ROOM_SCRIPT)
    add_child(room)
    if index == 0:
        room.set("room_title", "KOMMANDODECK")
        room.call("add_furniture","Command desk",Vector2(2.2,1.75),Vector2(2.6,1.1),1.15,Color("#536d79"))
        room.call("add_furniture","Terminal",Vector2(6.5,1.9),Vector2(1.25,1.0),1.05,Color("#315b65"))
        room.call("add_furniture","Planning table",Vector2(4.55,4.75),Vector2(2.5,1.25),0.85,Color("#5b6674"))
    else:
        room.set("room_title", "WARTUNGSKORRIDOR")
        room.call("add_furniture","Equipment",Vector2(1.6,1.4),Vector2(1.4,1.25),1.4,Color("#59616b"))
        room.call("add_furniture","Service panel",Vector2(7.3,1.4),Vector2(1.2,1.1),1.6,Color("#375365"))
        room.call("add_furniture","Cargo",Vector2(2.1,5.6),Vector2(1.5,1.0),0.8,Color("#776952"))
    actor.position = Vector3(4.3,0.0,3.4)
    actor.set("can_stand",Callable(room,"can_stand"))
    camera.position = Vector3(11.7,10.0,14.7) if index == 0 else Vector3(-4.5,7.5,13.8)
    camera.look_at(Vector3(4.5,0.8,3.35),Vector3.UP)
    heading.text = "ALIEN CRISIS / %s / DEMO 2.0" % room.get("room_title")
func _unhandled_key_input(ev: InputEvent) -> void:
    if not ev is InputEventKey or not ev.pressed or ev.echo:
        return
    if ev.keycode == KEY_ESCAPE:
        get_tree().quit()
    elif ev.keycode == KEY_F5:
        _build_room(1-active_room)
    elif ev.keycode == KEY_E:
        var pos := Vector2(actor.position.x,actor.position.z)
        if pos.distance_to(Vector2(8,5.3)) < 1.6:
            _build_room(1-active_room)
        else:
            message.text = "AUSGANG RECHTS HINTEN: F5 WECHSELT DEN RAUM JEDERZEIT"
