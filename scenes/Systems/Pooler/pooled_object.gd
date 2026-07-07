extends Node2D
class_name PooledObject

func set_active() -> void:
    # self.active = true
    self.visible = true
    set_deferred("monitoring", true)
    set_deferred("monitorable", true)
    set_process(true)

func set_inactive() -> void:
    # self.active = false
    self.visible = false
    set_deferred("monitoring", false)
    set_deferred("monitorable", false)
    set_process(false)
    position = Vector2.ONE * 100
