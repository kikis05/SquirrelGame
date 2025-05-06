extends Control
class_name DialogueBox

signal talk_finished                            # emitted when ALL lines done

@export var char_rate := 0.02                   # seconds per character

# cached nodes ------------------------------------------------------------
@onready var _label : Label = $"NinePatchRect/Line"
@onready var _hint  : Label          = $"NinePatchRect/ContinueHint"
@onready var _anim  : AnimationPlayer = $AnimationPlayer         # (optional)

# internal state ----------------------------------------------------------
var _lines  : PackedStringArray
var _idx    : int   = 0                         # which line are we on?
var _char_i : int   = 0                         # index into that line
var _timer  : Timer                             # created in _ready()


# ─────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = false
	add_child(_timer)
	_timer.timeout.connect(_type_next_char)

	_hint.visible = false                        # hide “Press E” initially


# ---------------- public API --------------------------------------------
func start(lines : PackedStringArray) -> void:
	_lines  = lines
	_idx    = 0
	if _anim: _anim.play("slide_in")             # optional nice entrance
	_show_line()


# ---------------- typing logic ------------------------------------------
func _show_line() -> void:
	_label.text = ""
	_char_i     = 0
	_hint.visible = false
	_timer.start(char_rate)

func _type_next_char() -> void:
	var txt := _lines[_idx]
	_label.text += txt[_char_i]
	_char_i += 1

	if _char_i >= txt.length():
		_timer.stop()
		_hint.visible = true                    # finished this line


# ---------------- input --------------------------------------------------
func _unhandled_input(event) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") \
	or event.is_action_pressed("interact"):
		_process_key_press()


func _process_key_press() -> void:
	# 1) still typing  → fast‑forward to end
	if _timer.time_left > 0.0:
		_timer.stop()
		_label.text = _lines[_idx]
		_hint.visible = true
		return

	# 2) more lines   → move to the next one
	if _idx < _lines.size() - 1:
		_idx += 1
		_show_line()
		return

	# 3) last line done → close box & emit signal
	_close_dialogue()


# ---------------- closing helper ----------------------------------------
func _close_dialogue() -> void:
	_hint.visible = false
	if _anim:
		_anim.play("slide_out")
		await _anim.animation_finished
	queue_free()
	emit_signal("talk_finished")
