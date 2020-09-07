extends Control

#========================================================
#Botón para iniciar una nueva partida
#========================================================
func _on_btnStartGame_Clicked():
	get_tree().change_scene("res://ui_scenes/game/Game.tscn")

#========================================================
#Botón para configurar el juego
#========================================================
func _on_btnSettings_Clicked():
	get_tree().change_scene("res://ui_scenes/game_settings/GameSettings.tscn")

#========================================================
#Botón para ver el ranking
#========================================================
func _on_btnRanking_Clicked():
	get_tree().change_scene("res://ui_scenes/ranking/Ranking.tscn")

#========================================================
#Botón para ver la pantalla de créditos
#========================================================
func _on_btnAbout_Clicked():
	get_tree().change_scene("res://ui_scenes/about/About.tscn")

#========================================================
#Botón para salir del juego
#========================================================
func _on_btnExitGame_Clicked():
	get_tree().quit()
