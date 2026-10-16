extends CharacterBody3D
## Shared controller used for every room and camera. Input uses world X/Z.
@export var speed := 3.5
@export var sprint_factor := 1.65
var can_stand: Callable
var visual: Node3D
func _ready() -> void:
    visual = Node3D.new()
    add_child(visual)
    _part(Vector3(0,0.45,0),Vector3(0.43,0.9,0.35),Color("#263c48"))
    _part(Vector3(0,1.15,0),Vector3(0.8,0.83,0.53),Color("#687f80"))
    _part(Vector3(0,1.79,0),Vector3(0.56,0.48,0.57),Color("#96a8a4"))
    _part(Vector3(0,1.82,0.3),Vector3(0.41,0.12,0.08),Color("#51d2d7"))
func _part(at: Vector3,dimensions: Vector3,tint: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    node.mesh = mesh
    node.position = at
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    node.material_override = material
    visual.add_child(node)
func _physics_process(delta: float) -> void:
    var input_dir := Input.get_vector("move_left","move_right","move_up","move_down")
    var motion := input_dir * speed * (sprint_factor if Input.is_key_pressed(KEY_SHIFT) else 1.0) * delta
    var px := Vector2(position.x,position.z)
    if can_stand.is_valid():
        if can_stand.call(px+Vector2(motion.x,0)):
            position.x += motion.x
        if can_stand.call(Vector2(position.x,position.z+motion.y)):
            position.z += motion.y
    if input_dir.length_squared() > 0.01:
        visual.rotation.y = atan2(input_dir.x,input_dir.y)
