extends Stun_State

func on_timer_finished():
	if enemy.health <= 0:
		transitioned.emit(self, "death state")
	else:
		transitioned.emit(self, "linear chase state") ## Created this extension for the linear chase state
		
