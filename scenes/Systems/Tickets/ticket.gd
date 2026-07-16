extends Node
class_name Ticket

enum TicketRequest {
    NONE,
    EXTRA,
    LESS,
    ALERGEN,
}

signal ticket_expired(ticket: Ticket)

@export var id: int = 0
@export var time_limit: float = 90
@export var dish_id: int = 0
@export var dish_request: Dictionary = Dictionary()
# dish_request should follow { ingredient_id: TicketRequest } format, logic handled in TicketManager

var timer: Timer

func _timout_ticket() -> void:
    ticket_expired.emit(self)
