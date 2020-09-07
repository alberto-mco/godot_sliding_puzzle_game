extends Control

#=========================================================================
#Initialize
#=========================================================================
func _ready():
	#Inicializamos los controles del formulario
	InitializeSceneControls()
	
	#Cargamos la configuración actual y la mostramos en pantalla
	LoadSettings()

#=========================================================================
#Carga el fichero de configuración y muestra la configuración actual
#=========================================================================
func LoadSettings():
	#Cargamos los parámetros de configuración actuales
	$gbSettings/VBoxContainer/GridContainer/obBoardSize.select(Settings.BoardSizeType)
	$gbSettings/VBoxContainer/GridContainer/spShuffleMoves.value = Settings.TotalShuffleMoves

#=========================================================================
#Inicializa los controles de la escena
#=========================================================================
func InitializeSceneControls():
	#Insertamos los diferentes tamaños de tablero
	$gbSettings/VBoxContainer/GridContainer/obBoardSize.add_item("3x3")
	$gbSettings/VBoxContainer/GridContainer/obBoardSize.add_item("4x4")
	$gbSettings/VBoxContainer/GridContainer/obBoardSize.add_item("5x5")

#=========================================================================
#Función para volver al menú principal
#=========================================================================
func _on_btnBack_Clicked():
	get_tree().change_scene(Settings.MainScene)

#=========================================================================
#Función para guardar la configuración del juego en la base de datos
#=========================================================================
func _on_btnSave_Clicked():
	#Guardamos los parámetros configurados por el usuario
	Settings.BoardSizeType = $gbSettings/VBoxContainer/GridContainer/obBoardSize.get_selected_id()
	Settings.TotalShuffleMoves = $gbSettings/VBoxContainer/GridContainer/spShuffleMoves.value
	
	#Guardamos la configuración en la base de datos
	Settings.SaveSettings()
	
	#Volvemos a la escena principal
	get_tree().change_scene(Settings.MainScene)
