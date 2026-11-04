extends Control

const STARTING_LP := 8000
const STARTING_HAND := 5
const DECK_SIZE := 40

var player_lp := STARTING_LP
var cpu_lp := STARTING_LP
var turn_number := 1
var player_turn := true
var deck: Array[Dictionary] = []
var hand: Array[Dictionary] = []
var player_field: Array[Dictionary] = []
var cpu_field: Array[Dictionary] = []
var log_lines: Array[String] = []

var title_label: Label
var status_label: Label
var lp_label: Label
var hand_label: Label
var field_label: Label
var log_label: Label
var action_row: HBoxContainer
var draw_button: Button
var summon_button: Button
var attack_button: Button
var end_button: Button
var restart_button: Button

func _ready() -> void:
    _build_deck()
    _build_ui()
    _start_duel()

func _build_deck() -> void:
    deck.clear()
    for i in range(DECK_SIZE):
        var card_type := "monster"
        var attack := 1000 + ((i * 173) % 1800)
        var defense := 800 + ((i * 137) % 1600)
        var name := "Training Monster %02d" % (i + 1)
        if i % 8 == 0:
            card_type = "spell"
            attack = 0
            defense = 0
            name = "Training Spell %02d" % (i + 1)
        elif i % 11 == 0:
            card_type = "trap"
            attack = 0
            defense = 0
            name = "Training Trap %02d" % (i + 1)
        deck.append({
            "name": name,
            "type": card_type,
            "atk": attack,
            "def": defense
        })
    deck.shuffle()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#101a2b")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 18)
    margin.add_theme_constant_override("margin_right", 18)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 18)
    add_child(margin)

    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 12)
    margin.add_child(root)

    title_label = _label("LEGEND REBORN", 30, Color("#f4d36b"))
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    root.add_child(title_label)

    status_label = _label("Preparing duel...", 18, Color.WHITE)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    root.add_child(status_label)

    var cpu_panel := _panel()
    root.add_child(cpu_panel)
    var cpu_box := VBoxContainer.new()
    cpu_panel.add_child(cpu_box)
    cpu_box.add_child(_label("OPPONENT", 17, Color("#ff9b9b")))
    lp_label = _label("", 23, Color.WHITE)
    cpu_box.add_child(lp_label)
    field_label = _label("", 16, Color("#d8e5ff"))
    field_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    cpu_box.add_child(field_label)

    var center := _label("— DUEL FIELD —", 16, Color("#f4d36b"))
    center.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    root.add_child(center)

    var player_panel := _panel()
    root.add_child(player_panel)
    var player_box := VBoxContainer.new()
    player_panel.add_child(player_box)
    player_box.add_child(_label("YOU", 17, Color("#8fe0b0")))
    hand_label = _label("", 15, Color.WHITE)
    hand_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    player_box.add_child(hand_label)

    log_label = _label("", 13, Color("#c4d0e5"))
    log_label.custom_minimum_size = Vector2(0, 115)
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(log_label)

    action_row = HBoxContainer.new()
    action_row.add_theme_constant_override("separation", 6)
    root.add_child(action_row)

    draw_button = _button("DRAW", _on_draw)
    summon_button = _button("SUMMON", _on_summon)
    attack_button = _button("ATTACK", _on_attack)
    end_button = _button("END TURN", _on_end_turn)
    action_row.add_child(draw_button)
    action_row.add_child(summon_button)
    action_row.add_child(attack_button)
    action_row.add_child(end_button)

    restart_button = _button("NEW DUEL", _on_restart)
    root.add_child(restart_button)

func _label(text: String, size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)
    return label

func _panel() -> PanelContainer:
    var panel := PanelContainer.new()
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#1b2a42")
    style.border_color = Color("#526987")
    style.set_border_width_all(2)
    style.set_corner_radius_all(10)
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    panel.add_theme_stylebox_override("panel", style)
    return panel

func _button(text: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.custom_minimum_size = Vector2(0, 54)
    button.add_theme_font_size_override("font_size", 15)
    button.pressed.connect(callback)
    return button

func _start_duel() -> void:
    player_lp = STARTING_LP
    cpu_lp = STARTING_LP
    turn_number = 1
    player_turn = true
    player_field.clear()
    cpu_field.clear()
    hand.clear()
    _build_deck()
    for i in range(STARTING_HAND):
        _draw_to_hand()
    log_lines.clear()
    _log("Duel started. You go first.")
    _refresh()

func _draw_to_hand() -> void:
    if deck.is_empty():
        _log("Your deck is empty!")
        return
    if hand.size() >= 7:
        _log("Your hand is full (7 cards).")
        return
    hand.append(deck.pop_back())

func _on_draw() -> void:
    if not _can_player_act():
        return
    _draw_to_hand()
    _log("You drew a card.")
    _refresh()

func _on_summon() -> void:
    if not _can_player_act():
        return
    if not player_field.is_empty():
        _log("You already control a monster in this prototype.")
        return
    var index := -1
    for i in range(hand.size()):
        if hand[i]["type"] == "monster":
            index = i
            break
    if index == -1:
        _log("No monster in your hand to summon.")
        return
    var card: Dictionary = hand.pop_at(index)
    player_field.append(card)
    _log("You summoned %s (%d ATK)." % [card["name"], card["atk"]])
    _refresh()

func _on_attack() -> void:
    if not _can_player_act():
        return
    if player_field.is_empty():
        _log("Summon a monster before attacking.")
        return
    var attacker: Dictionary = player_field[0]
    if cpu_field.is_empty():
        cpu_lp = max(0, cpu_lp - int(attacker["atk"]))
        _log("%s attacked directly for %d damage!" % [attacker["name"], attacker["atk"]])
    else:
        var defender: Dictionary = cpu_field[0]
        var difference := int(attacker["atk"]) - int(defender["atk"])
        if difference > 0:
            cpu_lp = max(0, cpu_lp - difference)
            cpu_field.clear()
            _log("Your monster destroyed the opponent's monster. %d damage!" % difference)
        elif difference < 0:
            player_lp = max(0, player_lp + difference)
            player_field.clear()
            _log("Your monster was destroyed. You took %d damage." % abs(difference))
        else:
            player_field.clear()
            cpu_field.clear()
            _log("Both monsters were destroyed!")
    _check_winner()
    _refresh()

func _on_end_turn() -> void:
    if not _can_player_act():
        return
    player_turn = false
    status_label.text = "Opponent's turn..."
    _refresh()
    _cpu_turn()

func _cpu_turn() -> void:
    if cpu_lp <= 0 or player_lp <= 0:
        return
    if deck.size() > 0:
        deck.pop_back()
    if cpu_field.is_empty():
        var cpu_card := {
            "name": "CPU Training Monster",
            "type": "monster",
            "atk": 1100 + ((turn_number * 211) % 1900),
            "def": 1000
        }
        cpu_field.append(cpu_card)
        _log("Opponent summoned a monster (%d ATK)." % cpu_card["atk"])
    elif not player_field.is_empty():
        var cpu_atk := int(cpu_field[0]["atk"])
        var player_atk := int(player_field[0]["atk"])
        if cpu_atk > player_atk:
            player_lp = max(0, player_lp - (cpu_atk - player_atk))
            player_field.clear()
            _log("Opponent destroyed your monster. You took %d damage." % (cpu_atk - player_atk))
        elif cpu_atk < player_atk:
            cpu_lp = max(0, cpu_lp - (player_atk - cpu_atk))
            cpu_field.clear()
            _log("Your monster survived and destroyed the opponent's monster!")
        else:
            player_field.clear()
            cpu_field.clear()
            _log("Both monsters were destroyed in battle.")
    else:
        player_lp = max(0, player_lp - int(cpu_field[0]["atk"]))
        _log("Opponent attacked directly for %d damage." % int(cpu_field[0]["atk"]))
    _check_winner()
    if player_lp > 0 and cpu_lp > 0:
        turn_number += 1
        player_turn = true
        _draw_to_hand()
        _log("Your turn. Draw phase complete.")
    _refresh()

func _on_restart() -> void:
    _start_duel()

func _can_player_act() -> bool:
    if not player_turn:
        _log("Wait for your turn.")
        return false
    if player_lp <= 0 or cpu_lp <= 0:
        _log("The duel is over. Start a new duel.")
        return false
    return true

func _check_winner() -> void:
    if player_lp <= 0:
        player_lp = 0
        player_turn = false
        _log("DEFEAT! Tap NEW DUEL to play again.")
    elif cpu_lp <= 0:
        cpu_lp = 0
        player_turn = false
        _log("VICTORY! Tap NEW DUEL to play again.")

func _log(message: String) -> void:
    log_lines.append(message)
    while log_lines.size() > 5:
        log_lines.pop_front()

func _refresh() -> void:
    if not is_node_ready():
        return
    lp_label.text = "Opponent LP: %d" % cpu_lp
    var cpu_text := "Opponent field: "
    cpu_text += "Empty" if cpu_field.is_empty() else "%s — %d ATK" % [cpu_field[0]["name"], cpu_field[0]["atk"]]
    field_label.text = cpu_text
    var player_text := "Your LP: %d\nYour field: " % player_lp
    player_text += "Empty" if player_field.is_empty() else "%s — %d ATK" % [player_field[0]["name"], player_field[0]["atk"]]
    player_text += "\nHand (%d): " % hand.size()
    for i in range(hand.size()):
        var card: Dictionary = hand[i]
        player_text += "\n%d. %s [%s]" % [i + 1, card["name"], card["type"]]
    hand_label.text = player_text
    log_label.text = "DUEL LOG\n" + "\n".join(log_lines)
    status_label.text = "YOUR TURN — Turn %d" % turn_number if player_turn else "OPPONENT TURN"
    draw_button.disabled = not player_turn
    summon_button.disabled = not player_turn
    attack_button.disabled = not player_turn
    end_button.disabled = not player_turn
