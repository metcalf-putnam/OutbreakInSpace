extends Node

# Dialogue signals 
signal new_dialogue
signal dialogue_finished
signal player_spoke
signal npc_dialogue
signal going_in_house_dialogue
signal going_out_house_dialogue
signal tv_dialogue
signal bed_dialogue
signal computer_dialogue
signal pet_dialogue

# Energy use signals
signal energy_used
signal insufficient_energy

# Day signals
signal day_ended
signal work_ended
signal leave_building

# Testing signals
signal testing_character
signal character_tested

# Building signals
signal building_entered
signal building_exited
signal building_occupied

# Infection signals
signal new_infection

# Mini game
signal start_mini_game

# Onscreen control signals
signal sing_button_pressed
signal sing_button_released
signal sing_button_toggled
signal test_button_pressed

# Player house
signal house_entered
signal house_exited
signal tv_interaction
signal bed_interaction
signal computer_interaction
signal pet_interaction

# Ending signal
signal restart_game
