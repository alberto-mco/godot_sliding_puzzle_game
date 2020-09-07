tool
extends Control

export(String) onready var Text setget SetTexto, GetTexto
export(int) onready var FontSize setget SetFontSize, GetFontSize

export(bool) onready var ShowCloseButton setget SetShowCloseButton, GetShowCloseButton

signal CloseButtonClicked

#=========================================================================
#Cambia el texto del botón
#=========================================================================
func SetTexto(pValue:String):
	#Comprobamos si se puede editar la propiedad del control
	if has_node("Header/lblText"):
		$Header/lblText.text = pValue
	Text = pValue

#=========================================================================
#Obtiene el texto del botón
#=========================================================================
func GetTexto()->String:
	var mResult:String = ""
	
	#Comprobamos si se puede leer la propiedad del control
	if has_node("Header/lblText"):
		mResult = $Header/lblText.text
	else:
		mResult = Text
	
	return mResult

#=========================================================================
#Cambia el tamaño de la letra
#=========================================================================
func SetFontSize(pValue:int):
	#Comprobamos si se puede editar la propiedad del control
	if has_node("Header/lblText"):
		$Header/lblText.get("custom_fonts/font").size = pValue
	FontSize = pValue

#=========================================================================
#Obtiene el tamaño de la letra
#=========================================================================
func GetFontSize()->int:
	var iResult = 0
	
	if has_node("Header/lblText"):
		iResult = $Header/lblText.get("custom_fonts/font").size
	else:
		iResult = FontSize
	
	return iResult

#=========================================================================
#Muestra o oculta el botón de cerrar
#=========================================================================
func SetShowCloseButton(pValue:bool):
	#Comprobamos si se puede editar la propiedad del control
	if has_node("Header/btnCloseGroupBox"):
		$Header/btnCloseGroupBox.visible = pValue
	ShowCloseButton = pValue

#=========================================================================
#Muestra o oculta el botón de cerrar
#=========================================================================
func GetShowCloseButton()->bool:
	var bVisibleResult = false
	
	if has_node("Header/btnCloseGroupBox"):
		bVisibleResult = $Header/btnCloseGroupBox.visible
	else:
		bVisibleResult = ShowCloseButton
	
	return bVisibleResult

#=========================================================================
#Capturamos la señal que emite el botón texturizado
#=========================================================================
func _on_btnCloseGroupBox_pressed():
	emit_signal("CloseButtonClicked")
