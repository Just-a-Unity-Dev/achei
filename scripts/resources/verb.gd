extends Resource
class_name Verb

enum VerbType {
	## This verb can only be executed as a subject.
	SUBJECT_ONLY = 0,
	## This verb can only be executed as a target.
	TARGET_ONLY = 1,
	## This verb can be executed both as a target and a subject.
	BOTH = 2
}

enum SelectionType {
	## This verb does not require a target to select.
	NONE = 0,
	## This verb will request the player to select a point on screen.
	MOUSE = 1,
	## This verb will request the player to select a noun on screen.
	NOUN = 2
}

@export var verb_name: String
@export var verb_description: String
@export var verb_type: VerbType
@export var verb_image: Texture2D
@export var verb_selection_type: SelectionType
@export var input_event_name: String
@export var order: Script
