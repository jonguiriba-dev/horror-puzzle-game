@tool
extends StateChart
class_name LevelStateChart

@onready var states:={
	"load":$LevelStates/Load,
	"start_sequence":$LevelStates/StartSequence,
	"running":$LevelStates/Running,
	"ai_turn":$LevelStates/Running/AITurn,
	"player_turn":$LevelStates/Running/PlayerTurn,
	"end_sequence":$LevelStates/EndSequence,
	"unload":$LevelStates/Unload,
}
