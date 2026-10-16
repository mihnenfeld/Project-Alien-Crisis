extends Node3D
## Visual-only command deck dressing. All parts are aligned to the existing
## 9 x 7 metre room; walk collision remains owned by ac_room.gd.
func _ready() -> void:
    _build()

func _box(n: String, p: Vector3, size: Vector3, color: Color, glow: bool = false, metal: float = 0.45) -> void:
    var m := MeshInstance3D.new()
    m.name = n
    var shape := BoxMesh.new()
    shape.size = size
    m.mesh = shape
    m.position = p
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metal
    mat.roughness = 0.42
    if glow:
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 1.7
    m.material_override = mat
    add_child(m)

func _pipe(n: String, p: Vector3, length: float, radius: float, color: Color, horizontal: bool = true) -> void:
    var m := MeshInstance3D.new()
    m.name = n
    var tube := CylinderMesh.new()
    tube.top_radius = radius
    tube.bottom_radius = radius
    tube.height = length
    tube.radial_segments = 10
    m.mesh = tube
    m.position = p
    if horizontal:
        m.rotation_degrees.z = 90
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.7
    mat.roughness = 0.33
    m.material_override = mat
    add_child(m)

func _light(p: Vector3, c: Color, energy: float, reach: float) -> void:
    var l := OmniLight3D.new()
    l.position = p
    l.light_color = c
    l.light_energy = energy
    l.omni_range = reach
    add_child(l)

func _build() -> void:
    # Structurally consistent wall architecture. No decorative floor obstacles.
    for i in range(7):
        var x := 0.45 + i * 1.3
        _box("Rear rib %d" % i, Vector3(x, 1.8, 0.20), Vector3(0.12, 3.55, 0.22), Color("#74868a"))
        _box("Rib amber hazard %d" % i, Vector3(x, 0.45, 0.33), Vector3(0.08, 0.4, 0.025), Color("#9a7a3d"))
    _box("Bulkhead upper beam",Vector3(4.5,3.33,0.20),Vector3(9.0,0.32,0.42),Color("#202d37"))
    _box("Lower wall skirting",Vector3(4.5,0.20,0.25),Vector3(9,0.4,0.27),Color("#1d2d38"))
    for i in range(3):
        _pipe("Overhead conduit %d" % i,Vector3(4.5,3.12-i*0.13,0.39),8.4,0.038,Color("#273941"))
    # Monitor mounting frames; screen faces are luminous and stay correctly placed.
    for i in range(4):
        var x := 1.1 + i * 2.0
        _box("Screen bezel %d" % i,Vector3(x,2.25,0.25),Vector3(1.54,0.87,0.17),Color("#0d202c"))
        _box("Tactical display %d" % i,Vector3(x,2.25,0.35),Vector3(1.26,0.57,0.035),Color("#16677a"),true)
        for j in range(3):
            _box("Tactical lines",Vector3(x-0.42,2.36-j*0.13,0.38),Vector3(0.63-j*0.10,0.023,0.014),Color("#64c2cf"),true)
        _box("Status signal",Vector3(x+0.56,1.91,0.34),Vector3(0.08,0.04,0.04),Color("#e5a967"),true)
    # Command desk is exactly above its already existing collision rectangle.
    _box("Main console top",Vector3(2.2,1.20,1.75),Vector3(2.72,0.10,1.23),Color("#77898d"))
    _box("Command interface",Vector3(2.2,1.27,1.67),Vector3(1.82,0.04,0.73),Color("#145061"),true)
    for i in range(8):
        _box("Console key",Vector3(1.45+i*0.21,1.29,2.02),Vector3(0.10,0.025,0.05),Color("#78bec5"),true)
    _box("Command edge",Vector3(2.2,0.74,2.33),Vector3(2.62,0.10,0.08),Color("#9b7444"))
    # Right-side diagnostics.
    _box("Terminal shroud",Vector3(6.5,1.10,1.9),Vector3(1.34,0.12,1.1),Color("#87959a"))
    _box("Diagnostics luminous panel",Vector3(6.5,1.18,1.9),Vector3(0.97,0.03,0.76),Color("#238695"),true)
    _box("Terminal trim",Vector3(6.5,0.6,2.43),Vector3(1.25,0.12,0.06),Color("#b28a4e"))
    # Map table: render detail fits the pre-existing obstacle, unlike image masks.
    _box("Planning tabletop",Vector3(4.55,0.88,4.75),Vector3(2.62,0.09,1.33),Color("#697f86"))
    _box("Tactical map",Vector3(4.55,0.94,4.75),Vector3(1.90,0.018,0.86),Color("#164b5f"),true)
    for i in range(5):
        _box("Map route %d" % i,Vector3(3.88+i*0.31,0.96,4.75+sin(float(i))*0.2),Vector3(0.22,0.02,0.03),Color("#92cad1"),true)
    # Ceiling strips and cold pools of light.
    for i in range(3):
        var x := 1.8 + float(i)*2.6
        _box("Ceiling lamp housing",Vector3(x,3.25,1.28),Vector3(1.55,0.08,0.16),Color("#1a2832"))
        _box("Ceiling luminaire",Vector3(x,3.18,1.28),Vector3(1.28,0.025,0.1),Color("#b5dce4"),true)
        _light(Vector3(x,2.88,1.7),Color("#8dcfe0"),0.8,5.4)
    # Floor markings, not collision objects.
    for i in range(6):
        _box("Access stripe",Vector3(7.1+i*0.14,0.02,5.52),Vector3(0.065,0.012,0.6),Color("#b48a48"))
    _box("Door portal lintel",Vector3(8.8,2.65,5.0),Vector3(0.22,0.2,2.2),Color("#a3a99c"))
    _box("Door warning",Vector3(8.84,2.35,5.0),Vector3(0.14,0.09,0.45),Color("#b85c3d"),true)
    _light(Vector3(8.1,2.4,5.1),Color("#cc704e"),0.52,2.7)
