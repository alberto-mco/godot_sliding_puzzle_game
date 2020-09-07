extends Control

#=========================================================================
#Función para volver al menú principal
#=========================================================================
func _on_btnGoToMainMenu_Clicked():
	get_tree().change_scene(Settings.MainScene)
