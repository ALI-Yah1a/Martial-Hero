
extends Control

@onready var open_button: Button = $"Levels'Panel/OpenButton"
@onready var book_animation: AnimatedSprite2D = $"Levels'Panel/BookAnimation"
@onready var pages: Control = $"Levels'Panel/Pages"

@onready var previous_button: Button = $"Levels'Panel/Pages/PreviousButton"
@onready var next_button: Button = $"Levels'Panel/Pages/NextButton"
@onready var close_button: Button = $"Levels'Panel/CloseButton"

@onready var page_1: Control = $"Levels'Panel/Pages/Page1"
@onready var page_2: Control = $"Levels'Panel/Pages/Page2"
@onready var page_3: Control = $"Levels'Panel/Pages/Page3"
@onready var page_4: Control = $"Levels'Panel/Pages/Page4"
@onready var page_5: Control = $"Levels'Panel/Pages/Page5"
@onready var page_6: Control = $"Levels'Panel/Pages/Page6"

@onready var title_label_1: Label = $"Levels'Panel/Pages/Page1/Label"
@onready var title_label_2: Label = $"Levels'Panel/Pages/Page2/Label"
@onready var title_label_3: Label = $"Levels'Panel/Pages/Page3/Label"
@onready var title_label_4: Label = $"Levels'Panel/Pages/Page4/Label4"
@onready var title_label_5: Label = $"Levels'Panel/Pages/Page5/Label5"
@onready var title_label_6: Label = $"Levels'Panel/Pages/Page6/Label6"

@onready var difficulty_label_1: Label = $"Levels'Panel/Pages/Page1/Label2"
@onready var difficulty_label_2: Label = $"Levels'Panel/Pages/Page2/Label2"
@onready var difficulty_label_3: Label = $"Levels'Panel/Pages/Page3/Label2"
@onready var difficulty_label_4: Label = $"Levels'Panel/Pages/Page4/Label22"
@onready var difficulty_label_5: Label = $"Levels'Panel/Pages/Page5/Label222"

@onready var letter_animation: AnimatedSprite2D = $"Levels'Panel/LetterAnimation"
@onready var letter_button: Button = $"Levels'Panel/LetterButton"

@onready var scroll_animation: AnimatedSprite2D = $"Levels'Panel/ScrollAnimation"
@onready var scroll_button: Button = $"Levels'Panel/ScrollButton"



var letter_opened: bool = false
var letter_animating: bool = false




var scroll_is_open: bool = false
var scroll_is_animating: bool = false




var level_names: Array[String] = [
	"LEVEL 1",
	"LEVEL 2",
	"LEVEL 3",
	"LEVEL 4",
	"LEVEL 5",
	"END OF THE LEVELS"
]

var level_difficulties: Array[String] = [
	"DIFFICULTY: ★☆☆☆☆",
	"DIFFICULTY: ★★☆☆☆",
	"DIFFICULTY: ★★★☆☆",
	"DIFFICULTY: ★★★★☆",
	"DIFFICULTY: ★★★★★",
	"DIFFICULTY: ★★★★★"
]




var level_pages: Array[Control] = []
var title_labels: Array[Label] = []
var difficulty_labels: Array[Label] = []



var is_opening: bool = false
var is_open: bool = false
var is_turning_page: bool = false
var is_closing: bool = false


var page_pair: int = 0

var pending_page_direction: int = 0




func _ready() -> void:
	level_pages = [
		page_1,
		page_2,
		page_3,
		page_4,
		page_5,
		page_6
	]

	title_labels = [
		title_label_1,
		title_label_2,
		title_label_3,
		title_label_4,
		title_label_5,
		title_label_6
	]

	difficulty_labels = [
		difficulty_label_1,
		difficulty_label_2,
		difficulty_label_3,
		difficulty_label_4,
		difficulty_label_5
	]

	pages.hide()
	close_button.hide()

	if book_animation.sprite_frames != null:
		if book_animation.sprite_frames.has_animation("open"):
			book_animation.animation = "open"
			book_animation.stop()
			book_animation.frame = 0
		else:
			push_warning("Missing book animation: open")

	if not open_button.pressed.is_connected(open_book):
		open_button.pressed.connect(open_book)

	if not previous_button.pressed.is_connected(previous_pair):
		previous_button.pressed.connect(previous_pair)

	if not next_button.pressed.is_connected(next_pair):
		next_button.pressed.connect(next_pair)

	if not close_button.pressed.is_connected(close_book):
		close_button.pressed.connect(close_book)

	if not book_animation.animation_finished.is_connected(
		_on_book_animation_finished
	):
		book_animation.animation_finished.connect(
			_on_book_animation_finished
		)


	if letter_animation.sprite_frames != null:
		if letter_animation.sprite_frames.has_animation("open_letter"):
			letter_animation.stop()
			letter_animation.animation = "open_letter"
			letter_animation.frame = 0
		else:
			push_warning("Missing letter animation: open_letter")

	if not letter_button.pressed.is_connected(
		_on_letter_button_pressed
	):
		letter_button.pressed.connect(_on_letter_button_pressed)

	if not letter_animation.animation_finished.is_connected(
		_on_letter_animation_finished
	):
		letter_animation.animation_finished.connect(
			_on_letter_animation_finished
		)


	if scroll_animation.sprite_frames != null:
		if scroll_animation.sprite_frames.has_animation("scroll down"):
			scroll_animation.stop()
			scroll_animation.animation = "scroll down"
			scroll_animation.frame = 0
		else:
			push_warning("Missing scroll animation: scroll down")

	if not scroll_button.pressed.is_connected(
		_on_scroll_button_pressed
	):
		scroll_button.pressed.connect(_on_scroll_button_pressed)

	if not scroll_animation.animation_finished.is_connected(
		_on_scroll_animation_finished
	):
		scroll_animation.animation_finished.connect(
			_on_scroll_animation_finished
		)

	update_level_pages()




func open_book() -> void:
	if is_open or is_opening or is_closing:
		return

	if book_animation.sprite_frames == null:
		push_warning("BookAnimation has no SpriteFrames resource.")
		return

	if not book_animation.sprite_frames.has_animation("open"):
		push_warning("Missing book animation: open")
		return

	is_opening = true
	is_open = false

	open_button.disabled = true
	close_button.hide()
	pages.hide()

	book_animation.play("open")




func _on_book_animation_finished() -> void:
	match book_animation.animation:

		"open":
			is_opening = false
			is_open = true
			is_closing = false

			book_animation.stop()
			book_animation.frame = (
				book_animation.sprite_frames.get_frame_count("open") - 1
			)

			update_level_pages()
			pages.show()

		"page_turn":
			book_animation.stop()

			if pending_page_direction != 0:
				page_pair += pending_page_direction
				pending_page_direction = 0

			is_turning_page = false

			update_level_pages()
			pages.show()

		"close book":
			is_closing = false
			is_open = false
			is_opening = false
			is_turning_page = false
			pending_page_direction = 0

			book_animation.stop()

			if book_animation.sprite_frames.has_animation("open"):
				book_animation.animation = "open"
				book_animation.stop()
				book_animation.frame = 0

			pages.hide()
			close_button.hide()

			open_button.show()
			open_button.disabled = false




func update_level_pages() -> void:
	for page in level_pages:
		page.hide()

	var left_index: int = page_pair * 2
	var right_index: int = left_index + 1

	if left_index >= 0 and left_index < level_pages.size():
		level_pages[left_index].show()

	if right_index >= 0 and right_index < level_pages.size():
		level_pages[right_index].show()

	for i in range(title_labels.size()):
		title_labels[i].text = level_names[i]

	for i in range(difficulty_labels.size()):
		difficulty_labels[i].text = level_difficulties[i]

	previous_button.visible = page_pair > 0
	next_button.visible = page_pair < 2

	close_button.visible = page_pair == 2 and is_open




func turn_page(direction: int) -> void:
	if not is_open:
		return

	if is_opening or is_turning_page or is_closing:
		return

	var target_pair: int = page_pair + direction

	if target_pair < 0 or target_pair > 2:
		return

	if book_animation.sprite_frames == null:
		push_warning("BookAnimation has no SpriteFrames resource.")
		return

	if not book_animation.sprite_frames.has_animation("page_turn"):
		push_warning("Missing book animation: page_turn")
		return

	is_turning_page = true
	pending_page_direction = direction

	pages.hide()
	close_button.hide()

	book_animation.play("page_turn")


func next_pair() -> void:
	turn_page(1)


func previous_pair() -> void:
	turn_page(-1)



func close_book() -> void:
	if not is_open:
		return

	if is_opening or is_turning_page or is_closing:
		return

	if book_animation.sprite_frames == null:
		push_warning("BookAnimation has no SpriteFrames resource.")
		return

	if not book_animation.sprite_frames.has_animation("close book"):
		push_warning("Missing book animation: close book")
		return

	is_closing = true
	is_open = false
	pending_page_direction = 0

	pages.hide()
	close_button.hide()

	book_animation.play("close book")




func _on_letter_button_pressed() -> void:
	if letter_animating:
		return

	if letter_animation.sprite_frames == null:
		push_warning("LetterAnimation has no SpriteFrames resource.")
		return

	if not letter_opened:
		if not letter_animation.sprite_frames.has_animation("open_letter"):
			push_warning("Missing letter animation: open_letter")
			return

		letter_animating = true
		letter_animation.play("open_letter")
	else:
		if not letter_animation.sprite_frames.has_animation("close_letter"):
			push_warning("Missing letter animation: close_letter")
			return

		letter_animating = true
		letter_animation.play("close_letter")


func _on_letter_animation_finished() -> void:
	match letter_animation.animation:
		"open_letter":
			letter_opened = true
			letter_animating = false

		"close_letter":
			letter_opened = false
			letter_animating = false




func _on_scroll_button_pressed() -> void:
	if scroll_is_animating:
		return

	if scroll_animation.sprite_frames == null:
		push_warning("ScrollAnimation has no SpriteFrames resource.")
		return

	if not scroll_is_open:
		if not scroll_animation.sprite_frames.has_animation("scroll up"):
			push_warning("Missing scroll animation: scroll up")
			return

		scroll_is_animating = true
		scroll_animation.play("scroll up")
	else:
		if not scroll_animation.sprite_frames.has_animation("scroll down"):
			push_warning("Missing scroll animation: scroll down")
			return

		scroll_is_animating = true
		scroll_animation.play("scroll down")


func _on_scroll_animation_finished() -> void:
	match scroll_animation.animation:
		"scroll up":
			scroll_is_open = true
			scroll_is_animating = false

		"scroll down":
			scroll_is_open = false
			scroll_is_animating = false




func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return

	if is_opening or is_turning_page or is_closing:
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			next_pair()
			get_viewport().set_input_as_handled()

		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			previous_pair()
			get_viewport().set_input_as_handled()


func _on_backtomainbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_enter_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
