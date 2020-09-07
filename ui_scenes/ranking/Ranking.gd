extends Control

onready var mGroupBox:Dictionary = {"0" : $VBoxContainer/gbRanking_3x3/, "1" : $VBoxContainer/gbRanking_4x4/, "2" : $VBoxContainer/gbRanking_5x5/}
onready var mListas:Dictionary = {"0" : $VBoxContainer/gbRanking_3x3/il_3x3, "1" : $VBoxContainer/gbRanking_4x4/il_4x4, "2" : $VBoxContainer/gbRanking_5x5/il_5x5}

#=========================================================================
#Initialize
#=========================================================================
func _ready():
	#Cargamos las clasificaciones
	LoadRanking()

#=========================================================================
#Muestra las clasificaciones en pantalla
#=========================================================================
func LoadRanking():
	var db = DataBase.new()
	var mPos:int = 0
	
	#Creamos las cabeceras de las tablas
	for mKey in mListas.keys():
		mPos = 0
		mListas[mKey].add_item("Posición", null, false)
		mListas[mKey].add_item("Jugador", null, false)
		mListas[mKey].add_item("Segundos", null, false)
		mListas[mKey].add_item("Movimientos", null, false)
		
		#Recorremos todas las clasificaciones del tablero "3x3"
		for mItem in db.GetRankings(int(mKey)):
			mPos += 1
			mListas[mKey].add_item(str(mPos))
			mListas[mKey].add_item(mItem["Player"])
			mListas[mKey].add_item(GetFormattedtime(mItem["Seconds"]))
			mListas[mKey].add_item(str(mItem["Moves"]))
		
		#Comprobamos si no habia clasificaciones
		if (mPos == 0):
			#Ocultamos las categorias que no han tenido aún ninguna clasificación
			mGroupBox[mKey].visible = false
	
	#Liberamos la instancia de la clase para administrar la base de datos
	db.queue_free()

#=========================================================================
#Función para formatear el total de segundos transcurridos a [MM:SS]
#=========================================================================
func GetFormattedtime(pTotalSeconds:int)->String:
	var strResult = ""
	var mSeconds:int = pTotalSeconds % 60
	var mMinutes:float = pTotalSeconds / 60
	
	#Formateamos el total de segundos en partida
	strResult = "%02d:%02d" % [mMinutes, mSeconds]
	
	return strResult

#=========================================================================
#Función para volver al menú principal
#=========================================================================
func _on_btnGoToMainMenu_Clicked():
	get_tree().change_scene(Settings.MainScene)
