extends BaseOrder

func start() -> void:
	subject.clear_orders()
	super()
	end(true)
