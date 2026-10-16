extends "res://scripts/demo_outpost.gd"
## Experimental story encounter + CTB vertical slice. No third-party assets.
const VISIBLE_ENEMY := Vector2(1042, 369)
var roaming_enemy_alive := true
var story_encounter_done := false
var battle_active := false
var enemy_hp := 55
var hero_hp := 100
var medic_hp := 75
var action_points := 2
var clock := {"Soldat": 0, "Medic": 16, "Alien": 32}
var acting := ""
var battle_note := ""
var battle_box: PanelContainer
var battle_title: Label
var order_label: Label
var vitals_label: Label
var message_label: Label
var action_row: HBoxContainer
var battle_kind := ""
var battle_step := 0

func _ready() -> void:
    super._ready()
    hint_label.text = "WASD: LAUFEN   |   E: INTERAKTION   |   GEGNER BERUEHREN: KAMPF   |   ESC: ENDE"
    _build_battle_ui()
    announcement = "A-17: Generator pruefen, Schott oeffnen, Alien im Ostfluegel untersuchen."
    _update_status()

func _build_battle_ui() -> void:
    battle_box = PanelContainer.new()
    battle_box.position = Vector2(265, 130)
    battle_box.custom_minimum_size = Vector2(740, 430)
    ui.add_child(battle_box)
    var outer := MarginContainer.new()
    for margin_name in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
        outer.add_theme_constant_override(margin_name, 22)
    battle_box.add_child(outer)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 16)
    outer.add_child(column)
    battle_title = Label.new()
    battle_title.add_theme_font_size_override("font_size", 27)
    column.add_child(battle_title)
    order_label = Label.new()
    order_label.add_theme_font_size_override("font_size", 19)
    column.add_child(order_label)
    vitals_label = Label.new()
    vitals_label.add_theme_font_size_override("font_size", 19)
    column.add_child(vitals_label)
    message_label = Label.new()
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message_label.custom_minimum_size = Vector2(680, 95)
    column.add_child(message_label)
    action_row = HBoxContainer.new()
    action_row.add_theme_constant_override("separation", 12)
    column.add_child(action_row)
    _button("ANGRIFF", "attack")
    _button("TALENT: HEILEN", "heal")
    _button("SPEZIAL (1 AP)", "special")
    _button("DECKUNG", "defend")
    battle_box.visible = false

func _button(label_text: String, action: String) -> void:
    var button := Button.new()
    button.text = label_text
    button.custom_minimum_size = Vector2(145, 44)
    button.pressed.connect(func() -> void: _choose_action(action))
    action_row.add_child(button)

func _physics_process(delta: float) -> void:
    if battle_active:
        queue_redraw()
        return
    super._physics_process(delta)
    if roaming_enemy_alive and player.distance_to(VISIBLE_ENEMY) < 66:
        _start_battle("visible")

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if battle_active:
        if event.keycode == KEY_ESCAPE:
            get_tree().quit()
        return
    var trigger_story := event.keycode == KEY_E and generator_on and not story_encounter_done and player.distance_to(console_rect.get_center()) < 110
    super._unhandled_key_input(event)
    if trigger_story:
        _start_battle("story")

func _start_battle(kind: String) -> void:
    battle_kind = kind
    battle_active = true
    enemy_hp = 55 if kind == "visible" else 85
    clock = {"Soldat": 0, "Medic": 16, "Alien": 32}
    battle_step = 0
    battle_note = "SICHTKONTAKT! Ein Alien blockiert den Ostfluegel." if kind == "visible" else "ALARMSIGNAL! Beim Zugriff auf das Terminal bricht eine Kreatur aus dem Wartungsschacht."
    battle_box.visible = true
    battle_title.text = "FEINDKONTAKT  /  " + ("PATROUILLE" if kind == "visible" else "STORY: WARTUNGSSCHACHT")
    _next_turn()

func _next_turn() -> void:
    if not battle_active:
        return
    if enemy_hp <= 0:
        _finish_battle(true)
        return
    if hero_hp <= 0 and medic_hp <= 0:
        _finish_battle(false)
        return
    var alive: Array[String] = ["Soldat", "Medic", "Alien"]
    if hero_hp <= 0:
        alive.erase("Soldat")
    if medic_hp <= 0:
        alive.erase("Medic")
    alive.sort_custom(func(a: String, b: String) -> bool: return int(clock[a]) < int(clock[b]))
    acting = alive[0]
    battle_step += 1
    if acting == "Alien":
        var target := "Soldat" if hero_hp > 0 else "Medic"
        if target == "Soldat":
            hero_hp = max(0, hero_hp - 13)
        else:
            medic_hp = max(0, medic_hp - 13)
        battle_note = "Alien greift %s an: 13 Schaden." % target
        clock["Alien"] = int(clock["Alien"]) + 95
        _next_turn()
        return
    _refresh_ui()

func _refresh_ui() -> void:
    var entries: Array[String] = []
    var remaining: Array[String] = []
    for who in ["Soldat", "Medic", "Alien"]:
        if who == "Soldat" and hero_hp <= 0:
            continue
        if who == "Medic" and medic_hp <= 0:
            continue
        remaining.append(who)
    remaining.sort_custom(func(a: String,b: String) -> bool: return int(clock[a]) < int(clock[b]))
    for who in remaining:
        entries.append(who)
    order_label.text = "CTB-REIHENFOLGE: " + "  ->  ".join(entries) + "     |  AM ZUG: " + acting
    vitals_label.text = "Soldat %d/100 HP    Medic %d/75 HP    Alien %d HP    Spezial-AP: %d" % [hero_hp, medic_hp, enemy_hp, action_points]
    message_label.text = battle_note + "\nAktionen veraendern die Wartezeit bis zum naechsten Zug."
    for i in action_row.get_child_count():
        var b := action_row.get_child(i) as Button
        b.disabled = (acting != "Soldat" and i == 2) or (i == 2 and action_points <= 0) or (i == 1 and hero_hp >= 100 and medic_hp >= 75)

func _choose_action(action: String) -> void:
    if not battle_active or acting == "Alien":
        return
    var delay := 90
    match action:
        "attack":
            enemy_hp = max(0, enemy_hp - (20 if acting == "Soldat" else 12))
            battle_note = "%s greift an." % acting
        "heal":
            if acting == "Medic":
                hero_hp = min(100, hero_hp + 28)
                battle_note = "Medic versorgt den Soldaten (+28 HP)."
            else:
                hero_hp = min(100, hero_hp + 12)
                battle_note = "Soldat nutzt ein Medkit (+12 HP)."
            delay = 115
        "special":
            if acting != "Soldat" or action_points <= 0:
                return
            action_points -= 1
            enemy_hp = max(0, enemy_hp - 38)
            delay = 140
            battle_note = "PRAEZISIONSSCHUSS: 38 Schaden. Ein Spezial-AP verbraucht."
        "defend":
            delay = 55
            battle_note = "%s nimmt Deckung. Naechster Zug frueher." % acting
    clock[acting] = int(clock[acting]) + delay
    _next_turn()

func _finish_battle(victory: bool) -> void:
    battle_active = false
    battle_box.visible = false
    if victory:
        if battle_kind == "visible":
            roaming_enemy_alive = false
            announcement = "PATROUILLE BESIEGT. Terminal untersuchen; bei aktiviertem Generator wartet ein Story-Encounter."
        else:
            story_encounter_done = true
            announcement = "STORY-ENCOUNTER BESTANDEN. A-17 gesichert. Demo abgeschlossen!"
    else:
        announcement = "GRUPPE BESIEGT. Demo zurueckgesetzt."
        player = Vector2(220,447)
        hero_hp = 100
        medic_hp = 75
        action_points = 2
    _update_status()
    queue_redraw()

func _draw() -> void:
    super._draw()
    if roaming_enemy_alive:
        draw_circle(VISIBLE_ENEMY + Vector2(4,8), 22, Color(0,0,0,0.45))
        draw_circle(VISIBLE_ENEMY, 19, Color("#724c56"))
        draw_circle(VISIBLE_ENEMY + Vector2(-8,-8), 8, Color("#b65e66"))
        draw_circle(VISIBLE_ENEMY + Vector2(8,-8), 8, Color("#b65e66"))
        draw_circle(VISIBLE_ENEMY + Vector2(0,0), 7, Color("#df9c75"))
        draw_arc(VISIBLE_ENEMY,28,0,TAU,32,Color("#f27268"),2,true)
