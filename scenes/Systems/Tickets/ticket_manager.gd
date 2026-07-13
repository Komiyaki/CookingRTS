extends Node
class_name TicketManager

@export var ticket_ui_manager: TicketUIManager

@export var tickets: Dictionary
@export var ticket_count: int = 0
@export var inactive_timers: Array[Timer]
@export var timer_scene: PackedScene
@export var ticket_capacity: int

# TODO: implement plate/ticket scoring
# @export var plate_zone:
# Object to detect completed dishes, pick them up and grade
# Reference to ui manager to handle ticket display

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    # Initialize ticket timers
    for i in range(ticket_capacity):
        var new_timer = timer_scene.instantiate()
        add_child(new_timer)
        new_timer.name = "%s %d" % ["Timer", i]
        inactive_timers.append(new_timer)


func first_setup(game_ui_manager: GameUIManager):
    ticket_ui_manager = game_ui_manager.ticket_ui_manager


func spawn_ticket() -> void:
    if len(inactive_timers) <= 0:
        return # We have too many tickets to make a new one

    var new_ticket: Ticket = Ticket.new()

    new_ticket.id = ticket_count
    ticket_count += 1

    # TODO: expand ticket dish selection
    new_ticket.dish_id = 1

    # TODO: add dish special requests
    new_ticket.time_limit += len(new_ticket.dish_request) * 10

    var new_timer = inactive_timers.pop_front()

    new_timer.wait_time = new_ticket.time_limit
    new_ticket.timer = new_timer

    new_timer.timeout.connect(new_ticket._timout_ticket, ConnectFlags.CONNECT_ONE_SHOT)
    new_ticket.ticket_expired.connect(_ticket_expired, ConnectFlags.CONNECT_ONE_SHOT)

    tickets.set(new_ticket.id, new_ticket)
    print("TicketManager - Created ticket id: %d" % new_ticket.id)

    ticket_ui_manager.add_ticket_ui(new_ticket)
    new_timer.start()




func _ticket_expired(ticket: Ticket) -> void:
    # reset and replace timer from ticket
    inactive_timers.append(ticket.timer)
    ticket.timer = null

    # remove ticket from active tickets
    tickets.erase(ticket.id)
    # TODO: save tickets to show at end?
