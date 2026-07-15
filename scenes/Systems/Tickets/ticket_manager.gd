extends Node
class_name TicketManager


@export var ticket_ui_manager: TicketUIManager

@export var plate_check_timer: Timer

@export var tickets: Dictionary # Tickets are stored as (ticketid, Ticket)
@export var ticket_count: int = 0
@export var inactive_timers: Array[Timer]
@export var timer_scene: PackedScene
@export var ticket_capacity: int

var random: RandomNumberGenerator
const DISH_DICTIONARY_LEN: int = len(RecipeDictionary.recipe_dict) - 1

@export var plate_process_queue: Array

# TODO: implement plate/ticket scoring
# @export var plate_zone:
# Object to detect completed dishes, pick them up and grade
# Reference to ui manager to handle ticket display

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Initialize and subscribe plate check timer
    plate_check_timer = Timer.new()
    add_child(plate_check_timer)
    plate_check_timer.name = "PlateCheckTimer"
    plate_check_timer.wait_time = GameData.PLATE_CHECK_INTERVAL
    plate_check_timer.one_shot = false
    plate_check_timer.timeout.connect(_check_completed_plates)
    plate_check_timer.start()

    # Init Random
    random = RandomNumberGenerator.new()
    random.seed = GameData.TICKET_MAN_RANDOM_SEED

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
    new_ticket.dish_id = random.randi_range(1, DISH_DICTIONARY_LEN)

    # TODO: add dish special requests
    new_ticket.time_limit += len(new_ticket.dish_request) * 10

    var new_timer = inactive_timers.pop_front()

    new_timer.wait_time = new_ticket.time_limit
    new_ticket.timer = new_timer

    new_timer.timeout.connect(new_ticket._timout_ticket, ConnectFlags.CONNECT_ONE_SHOT)
    new_ticket.ticket_expired.connect(_ticket_expired, ConnectFlags.CONNECT_ONE_SHOT)

    tickets.set(new_ticket.id, new_ticket)
    print("TicketManager - Created ticket id: %d" % new_ticket.id)

    # Add ticket to the UI and start timer
    ticket_ui_manager.add_ticket_ui(new_ticket)
    new_timer.start()


func _ticket_expired(ticket: Ticket) -> void:
    # reset and replace timer from ticket
    inactive_timers.append(ticket.timer)
    ticket.timer = null

    # remove ticket from active tickets
    tickets.erase(ticket.id)
    # TODO: save tickets to show at end?


func _check_completed_plates() -> void:
    # check each plate against tickets, starting with the earliest ticket
    var plates_to_complete: Array

    for plate in plate_process_queue:
        var ticket_id_to_complete: int

        for ticket in tickets:
            # check ticket order against plate contents (margin of +- 1???)
            # if we find a ticket close enough, select this ticket and break
            ticket_id_to_complete = ticket.id
            pass

        if ticket_id_to_complete == null:
            break
        # else grade current plate successfull, mark to remove from queue
        plates_to_complete.append(plate)
        # remove ticket_to_complete from tickets
        tickets.erase(ticket_id_to_complete)

    # clean up completed plates
    for plate in plates_to_complete:
        plate_process_queue.erase(plate)


func grade_plate(ingredients: Dictionary) -> bool:
    return true
