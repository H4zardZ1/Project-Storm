extends Node


func exit_game():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

	await get_tree().process_frame

	get_tree().quit()
