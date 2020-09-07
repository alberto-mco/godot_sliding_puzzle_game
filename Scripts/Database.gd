extends Node

class_name DataBase

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
const DatabaseSchemaPath:String = "res://database_schema/sliding_puzzle_data.json"
const DatabasePath:String = "user://sliding_puzzle_data.db"
var db
var db_name : String = ""

#Nombres de las tablas
var mRankingTableName:String = "Rankings"
var mSettings:String = "Settings"

#=========================================================================
#Inicializa la clase
#=========================================================================
func _init():
	randomize()
	#Comprobamos si la base de datos existe
	if (ExistsFile(DatabasePath) == false):
		#Creamos la base de datos
		CreateDatabaseSchema()

#=========================================================================
#Comprueba si el fichero existe
#=========================================================================
func ExistsFile(pPath:String)->bool:
	var mResult:bool = false
	var mFile = File.new()
	
	#Comprobamos si el fichero existe
	mResult = mFile.file_exists(pPath)
	
	#Retornamos el resultado de la operación
	return mResult

#=========================================================================
#Crea la base de datos local
#=========================================================================
func CreateDatabaseSchema():
	#Creamos una nueva instancia para administrar la base de datos
	db = SQLite.new()
	
	#Establecemos la ruta de la base de datos
	db.path = DatabasePath
	db.verbose_mode = false
	
	#Abrimos la base de datos
	db.open_db()
	
	#Creamos la estructura de la base de datos
	db.import_from_json(DatabaseSchemaPath)
	
	#Cerramos la base de datos
	db.close_db()

#=========================================================================
#Guarda el esquema de la base de datos (solo para programadores en tiempo de diseño, por si hay cambios)
#=========================================================================
func SaveSchema():
	#Creamos una nueva instancia para administrar la base de datos
	db = SQLite.new()
	
	#Establecemos la ruta de la base de datos
	db.path = DatabasePath
	db.verbose_mode = false
	
	#Abrimos la base de datos
	db.open_db()
	
	#Creamos la estructura de la base de datos
	db.export_to_json(DatabaseSchemaPath)
	
	#Cerramos la base de datos
	db.close_db()

#=========================================================================
#Función para añadir un resultado a la base de datos
#=========================================================================
func AddRankingResult(pBoardSizeType:int, pTotalSeconds:int, pTotalMoves:int, pUsername:String):
	#Creamos una nueva instancia para administrar la base de datos
	db = SQLite.new()
	
	#Establecemos la ruta de la base de datos
	db.path = DatabasePath
	db.verbose_mode = false
	
	#Abrimos la base de datos
	db.open_db()
	
	#Eliminamos el ranking anterior (por si ya existía de otro usuario)
	db.delete_rows(mRankingTableName, "BoardType = %d and Seconds = %d and Moves = %d" % [pBoardSizeType, pTotalSeconds, pTotalMoves])
	
	#Creamos el nuevo registro
	db.insert_row(mRankingTableName, {"BoardType" : pBoardSizeType, "Seconds" : pTotalSeconds, "Moves" : pTotalMoves, "Player" : pUsername})
	
	#Cerramos la base de datos
	db.close_db()

#=========================================================================
#Función para saber si los datos de la partida han ganado una plaza en el ranking de los mejores
#=========================================================================
func IsGameResultClasified(pBoardSizeType:int, pTotalSeconds:int, pTotalMoves:int)->bool:
	return true

#=========================================================================
#Función para eliminar las puntuaciones que han quedado desclasificadas de las mejores
#=========================================================================
func EraseNonClasifiedResults(pBoardSizeType:int):
	pass

#=========================================================================
#Obtiene el ranking de los mejores en el tablero especificado
#=========================================================================
func GetRankings(pBoardType:int)->Array:
	var mResult:Array
	
	#Creamos una nueva instancia para administrar la base de datos
	db = SQLite.new()
	
	#Establecemos la ruta de la base de datos
	db.path = DatabasePath
	db.verbose_mode = false
	
	#Abrimos la base de datos
	db.open_db()
	
	#Ejecutamos la sentencia SQL y guardamos el resultado
	mResult = db.select_rows(mRankingTableName, "BoardType = " + str(pBoardType), ["Seconds", "Moves", "Player"])
	
	#Cerramos la base de datos
	db.close_db()
	
	return mResult

#=========================================================================
#Obtiene la configuración del juego
#=========================================================================
func GetSettings()->Dictionary:
	var mResult:Dictionary = {}
	
	#Creamos una nueva instancia para administrar la base de datos
	db = SQLite.new()
	
	#Establecemos la ruta de la base de datos
	db.path = DatabasePath
	db.verbose_mode = false
	
	#Abrimos la base de datos
	db.open_db()
	
	#Ejecutamos la sentencia SQL y guardamos el resultado
	var mSqlResult:Array = db.select_rows(mSettings, "", ["BoardType", "ShuffleMoves"])
	
	#Comprobamos si se ha obtenido la configuración del juego
	if (mSqlResult.size() > 0):
		mResult = mSqlResult[0]
	
	#Cerramos la base de datos
	db.close_db()
	
	return mResult

#=========================================================================
#Guarda la configuración del juego
#=========================================================================
func SaveSettings(pBoardType:int, pShuffeMoves:int):
	#Creamos una nueva instancia para administrar la base de datos
	db = SQLite.new()
	
	#Establecemos la ruta de la base de datos
	db.path = DatabasePath
	db.verbose_mode = false
	
	#Abrimos la base de datos
	db.open_db()
	
	#Actualizamos en base de datos la configuración del juego
	db.update_rows(mSettings, "ID = 1", {"BoardType" : pBoardType, "ShuffleMoves" : pShuffeMoves})
	
	#Cerramos la base de datos
	db.close_db()
