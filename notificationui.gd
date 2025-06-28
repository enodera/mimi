extends CanvasLayer

@onready var notification_label_template = preload("res://LabelScenes/NotificationLabel.tscn")

var notification_queue: Array = []
var is_showing = false
var notifications: Array = []

func show_notification(text: String, duration: float = 2.0):
	print("Queued notification:", text)
	notification_queue.append({ "text": text, "duration": duration })
	if not is_showing:
		print("Starting queue processing")
		await process_queue()

func process_queue():
	is_showing = true
	while notification_queue.size() > 0:
		# Wait if we already have 3 notifications visible
		while notifications.size() >= 5:
			print("Max notifications active (5). Waiting...")
			await get_tree().create_timer(2.5).timeout
			notifications = []

		var data = notification_queue.pop_front()
		print("Popped from queue:", data.text)
		await get_tree().create_timer(0.25).timeout
		print("Showing notification:", data.text)
		_display_notification(data.text, data.duration)
	is_showing = false
	print("Finished queue processing")

func _display_notification(text: String, duration: float):
	
	var index = notifications.size()
	print("Displaying new notification:", text, "| Index:", index)

	var new_notification = notification_label_template.instantiate()
	add_child(new_notification)
	new_notification.text = text
	new_notification.visible = true
	new_notification.modulate.a = 0.0

	print()
	print()
	print(index)
	print(notifications)
	print()
	print()


	# Determine target position
	var base_x = new_notification.position.x
	var base_y = 100 + index * 40
	var target_pos = Vector2(base_x, base_y)
	print("Target position:", target_pos)

	new_notification.position = target_pos + Vector2(300, 0)  # start offscreen to the right
	notifications.append(new_notification)
	print("Current active notifications:", notifications.size())

	# Animate in
	var tween_in = create_tween()
	tween_in.tween_property(new_notification, "modulate:a", 1.0, 0.4)
	tween_in.tween_property(new_notification, "position", target_pos, 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(duration).timeout
	print("Notification expired:", text)
	await fade_out_and_remove(new_notification)

func fade_out_and_remove(notif_instance):
	print("Fading out notification:", notif_instance.text)
	var tween_out = create_tween()
	tween_out.tween_property(notif_instance, "modulate:a", 0.0, 0.4)

	await tween_out.finished
	remove_notification(notif_instance)

func remove_notification(notif_instance):
	print("Removing notification:", notif_instance.text)
	notifications.erase(notif_instance)
	notif_instance.queue_free()
	update_notification_positions()

func update_notification_positions():
	print("Updating positions for", notifications.size(), "notifications.")
	for i in range(notifications.size()):
		var notif_instance = notifications[i]
		var target_y = 100 + i * 40
		var tween = create_tween()
		tween.tween_property(notif_instance, "position:y", target_y, 0.3)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		print(" - Moving notification", notif_instance.text, "to y =", target_y)
