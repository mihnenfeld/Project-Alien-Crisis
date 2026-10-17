extends "res://scripts/ac_character.gd"
## Character-kit test avatar; reuses established PAC controls unchanged.
const MODEL_PATH := "res://assets/library/characters/quaternius_base_standard/Superhero_Male_FullBody.gltf"

func _ready() -> void:
    super._ready()
    if not ResourceLoader.exists(MODEL_PATH):
        push_warning("CharacterKit noch nicht installiert: " + MODEL_PATH)
        return
    var resource := load(MODEL_PATH) as PackedScene
    if resource == null:
        push_warning("Charaktermodell konnte nicht geladen werden.")
        return
    # Replace only placeholder visualization; never change player controller.
    for child in visual.get_children():
        child.queue_free()
    var model := resource.instantiate()
    model.name = "QuaterniusBaseCharacter"
    visual.add_child(model)
    var bounds := _visual_bounds(model)
    if bounds.size.y > 0.01:
        var factor := 1.8 / bounds.size.y
        model.scale = Vector3.ONE * factor
        model.position = Vector3(-bounds.get_center().x * factor, -bounds.position.y * factor, -bounds.get_center().z * factor)

func _visual_bounds(root: Node) -> AABB:
    var result := AABB()
    var first := true
    for item in root.find_children("*", "MeshInstance3D", true, false):
        var mesh := item as MeshInstance3D
        if mesh.mesh == null:
            continue
        var bounds := mesh.global_transform * mesh.get_aabb()
        if first:
            result = bounds
            first = false
        else:
            result = result.merge(bounds)
    return result
