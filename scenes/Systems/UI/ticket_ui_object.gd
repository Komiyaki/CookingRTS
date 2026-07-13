extends Control
class_name TicketUIObject

@export var timer_indicator: TextureProgressBar
@export var ticket_label: Label
# @export var ticket: Ticket
@export var ticket_timer: Timer

var id: int = 0

signal ticket_ui_expired

func first_setup(ticket: Ticket) -> void:
    # Add UI dish name label
    name = "TicketUI %d" % ticket.id
    ticket_label.text = RecipeDictionary.recipe_dict.get(ticket.dish_id).get(RecipeDictionary.RECIPE_NAME)
    ticket_timer = ticket.timer
    # set maxvalue for indicator
    timer_indicator.max_value = ticket_timer.wait_time
    # connect to ticket expire event
    ticket.timer.timeout.connect(_ticket_timer_expired, ConnectFlags.CONNECT_ONE_SHOT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    # timer_indicator.text = "%d:%02d" % [floor(_ticket_timer.time_left / 60), int(_ticket_timer.time_left) % 60]
    timer_indicator.value = ticket_timer.time_left
    pass


func _ticket_timer_expired():
    ticket_ui_expired.emit(self)
