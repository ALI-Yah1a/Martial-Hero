
extends Control



@onready var open_button: Button = $OpenButton
@onready var book_animation: AnimatedSprite2D = $BookAnimation
@onready var pages: Control = $Pages

@onready var previous_button: Button = $Pages/PreviousButton
@onready var next_button: Button = $Pages/NextButton



@onready var page_1: Control = $Pages/Page1
@onready var page_2: Control = $Pages/Page2
@onready var page_3: Control = $Pages/Page3
@onready var page_4: Control = $Pages/Page4
@onready var page_5: Control = $Pages/Page5
@onready var page_6: Control = $Pages/Page6




@onready var title_1: Label = $Pages/Page1/Label
@onready var title_2: Label = $Pages/Page2/Label
@onready var title_3: Label = $Pages/Page3/Label
@onready var title_4: Label = $Pages/Page4/Label4
@onready var title_5: Label = $Pages/Page5/Label5
@onready var title_6: Label = $Pages/Page6/Label6




@onready var difficulty_1: Label = $Pages/Page1/Label2
@onready var difficulty_2: Label = $Pages/Page2/Label2
@onready var difficulty_3: Label = $Pages/Page3/Label2
@onready var difficulty_4: Label = $Pages/Page4/Label22
@onready var difficulty_5: Label = $Pages/Page5/Label222



var level_pages: Array[Control] = []
var title_labels: Array[Label] = []
var difficulty_labels: Array[Label] = []




var is_opening: bool = false
var is_open: bool = false
var is_turning_page: bool = false


var page_pair: int = 0
var pending_page_direction: int = 0



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
		title_1,
		title_2,
		title_3,
		title_4,
		title_5,
		title_6
	]

	difficulty_labels = [
		difficulty_1,
		difficulty_2,
		difficulty_3,
		difficulty_4,
		difficulty_5
	]

	
	pages.hide()

	
	book_animation.animation = "open"
	book_animation.stop()
	book_animation.frame = 0

	
	if not open_button.pressed.is_connected(open_book):
		open_button.pressed.connect(open_book)

	if not book_animation.animation_finished.is_connected(
		_on_book_animation_finished
	):
		book_animation.animation_finished.connect(
			_on_book_animation_finished
		)

	if not previous_button.pressed.is_connected(previous_pair):
		previous_button.pressed.connect(previous_pair)

	if not next_button.pressed.is_connected(next_pair):
		next_button.pressed.connect(next_pair)

	update_level_pages()





func open_book() -> void:

	if is_opening or is_open:
		return

	is_opening = true
	open_button.disabled = true

	book_animation.play("open")




func _on_book_animation_finished() -> void:

	match book_animation.animation:

		"open":
			is_opening = false
			is_open = true

			book_animation.stop()

			book_animation.frame = (
				book_animation.sprite_frames
				.get_frame_count("open") - 1
			)

			update_level_pages()
			pages.show()

		"page_turn":
			book_animation.stop()

			# Apply the new pair after the animation finishes.
			if pending_page_direction != 0:
				page_pair += pending_page_direction
				pending_page_direction = 0

			# Update and reveal the new levels.
			update_level_pages()
			pages.show()

			is_turning_page = false




func update_level_pages() -> void:

	var left_index: int = page_pair * 2
	var right_index: int = left_index + 1

	
	for page in level_pages:
		page.hide()

	
	level_pages[left_index].show()
	level_pages[right_index].show()

	
	for i in range(title_labels.size()):
		title_labels[i].text = level_names[i]

	
	for i in range(difficulty_labels.size()):
		difficulty_labels[i].text = level_difficulties[i]

	
	previous_button.visible = page_pair > 0
	next_button.visible = page_pair < 2




func turn_page(direction: int) -> void:

	if not is_open:
		return

	if is_turning_page:
		return

	var target_pair: int = page_pair + direction

	
	if target_pair < 0 or target_pair > 2:
		return

	
	if book_animation.sprite_frames == null:
		push_warning("BookAnimation has no SpriteFrames resource.")
		return

	
	if not book_animation.sprite_frames.has_animation("page_turn"):
		push_warning(
			"Missing 'page_turn' animation in BookAnimation."
		)
		return

	
	is_turning_page = true
	pending_page_direction = direction


	pages.hide()

	
	book_animation.play("page_turn")




func next_pair() -> void:
	turn_page(1)


func previous_pair() -> void:
	turn_page(-1)




func _unhandled_input(event: InputEvent) -> void:

	if not is_open:
		return

	if is_opening or is_turning_page:
		return

	if event is InputEventMouseButton and event.pressed:

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			next_pair()

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			previous_pair()
