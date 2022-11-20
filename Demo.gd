extends Node2D

func _process(_delta):
	#	Makes the dialogue UI always within the view
	dlg.rect_global_position = $Camera2D/UIContainer.rect_global_position
	

	#	Demo-related stuff
	$BtnStartDlg.visible = !dlg.active


func _on_BtnStartDlg_pressed():
	print(dlg.rect_position)
	print(dlg.rect_global_position)
	print("")
	print($Camera2D.position)
	print($Camera2D.global_position)
	dlg.start( "res://dlg/Sample Dialogue.tres" )
