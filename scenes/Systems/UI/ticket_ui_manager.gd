extends Container
class_name TicketUIManager

@export var ticket_ui_scene: PackedScene

var ticket_uis: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func add_ticket_ui(ticket: Ticket) -> void:
    var new_ticket_ui = ticket_ui_scene.instantiate() as TicketUIObject
    if new_ticket_ui is not TicketUIObject:
        push_error("ticket_ui_scene is not of type TicketUIObject on %s" % name)
        return

    new_ticket_ui.first_setup(ticket)

    add_child(new_ticket_ui)
    new_ticket_ui.ticket_ui_expired.connect(remove_ticket_ui)

    print("TicketUIManager - Created ticketui id: %d" % ticket.id)
    pass

func remove_ticket_ui(ticket_ui_obj: TicketUIObject) -> void:
    ticket_uis.erase(ticket_ui_obj.id)
    ticket_ui_obj.queue_free()
