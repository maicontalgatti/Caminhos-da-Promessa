@tool
extends EditorPlugin
## Adiciona a aba "Missões" ao painel inferior do editor.

const EditorPanel := preload("res://addons/quest_editor/quest_editor_panel.gd")

var _panel: Control


func _enter_tree() -> void:
	_panel = EditorPanel.new()
	_panel.name = "Missões"
	add_control_to_bottom_panel(_panel, "Missões")


func _exit_tree() -> void:
	if _panel:
		remove_control_from_bottom_panel(_panel)
		_panel.queue_free()
		_panel = null
