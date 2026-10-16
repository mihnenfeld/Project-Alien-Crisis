extends Node3D
## Reusable room geometry. Shared coordinates are metres; rendering and collisions agree.
@export var room_size := Vector2(9.0, 7.0)
@export var room_title := "COMMAND DECK"
@export var passage_right := false
var obstacles: Array[Rect2] = []
func _ready() -> void:
    _cube("Floor",Vector3(4.5,-0.11,3.5),Vector3(9,0.2,7),Color("#34434d"))
    _cube("Rear bulkhead",Vector3(4.5,1.8,0),Vector3(9,3.6,0.25),Color("#475965"))
    if passage_right:
        _cube("Right bulkhead north",Vector3(9,1.8,2.0),Vector3(0.25,3.6,4.0),Color("#2d404a"))
        _cube("Right bulkhead south",Vector3(9,1.8,6.5),Vector3(0.25,3.6,1.0),Color("#2d404a"))
    else:
        _cube("Right bulkhead",Vector3(9,1.8,3.5),Vector3(0.25,3.6,7),Color("#2d404a"))
    for i in range(9):
        _cube("Floor seam",Vector3(i+0.5,0.011,3.5),Vector3(0.02,0.02,6.85),Color("#69818b"))
    for i in range(7):
        _cube("Floor seam",Vector3(4.5,0.012,i+0.5),Vector3(8.85,0.02,0.02),Color("#69818b"))
    for i in range(4):
        _cube("Monitor",Vector3(1.1+float(i)*2.0,2.25,0.16),Vector3(1.35,0.7,0.12),Color("#177083"),true)
func add_furniture(label_text: String, center: Vector2, footprint: Vector2, height: float, tint: Color) -> void:
    obstacles.append(Rect2(center-footprint/2.0,footprint))
    _cube(label_text,Vector3(center.x,height/2.0,center.y),Vector3(footprint.x,height,footprint.y),tint)
func can_stand(p: Vector2, radius: float = 0.19) -> bool:
    if p.x < radius or p.y < radius or p.x > room_size.x-radius or p.y > room_size.y-radius:
        return false
    for obstacle in obstacles:
        if obstacle.grow(radius).has_point(p):
            return false
    return true
func _cube(label_text: String, pos: Vector3, size: Vector3, tint: Color, glow: bool=false) -> void:
    var instance := MeshInstance3D.new()
    instance.name = label_text
    var mesh := BoxMesh.new()
    mesh.size = size
    instance.mesh = mesh
    instance.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.metallic = 0.18
    mat.roughness = 0.68
    if glow:
        mat.emission_enabled = true
        mat.emission = tint
        mat.emission_energy_multiplier = 0.6
    instance.material_override = mat
    add_child(instance)
