//Manage Game Turns
switch(global.current_phase)
{
	case global.phase_dealing:
		//Deal 6 Cards to player and CPU
			
		//when cards are being dealt into hands
		audio_play_sound(snd_card, 1, false);
			
		if(ds_list_size(hand_computer) < hand_size){
			//DEAL TO CPU
				
			var card = deck[| ds_list_size(deck)-1];
			ds_list_delete(deck, ds_list_size(deck)-1);
			ds_list_add(hand_computer, card);
				
			//Give card its destination to move to
			var destination_x = global.card_x_positions[ds_list_size(hand_computer)-1];
			var destination_y = global.card_com_y;
				
			scr_move_card(card, destination_x, destination_y);
				
			score_computer_temp += card.kind;				
			//card.face_up = true;
		}
		else if (ds_list_size(hand_player) < hand_size){
			//DEAL TO PLAYER
				
			var card = deck[| ds_list_size(deck) -1]
			ds_list_delete(deck, ds_list_size(deck)-1);
			ds_list_add(hand_player, card);
		
			//code to move card visually
			var destination_x = global.card_x_positions[ds_list_size(hand_player)-1];
			var destination_y = global.card_player_y;
				
			scr_move_card(card, destination_x, destination_y);
				
			score_player_temp += card.kind;	
		}
		else{
			//Once all cards dealt turn players cards face up
			for(i = 0; i < hand_size; i++){
				hand_player[|i].face_up = true;
			}
			//Update Scores
			global.score_computer = score_computer_temp;
			global.score_player = score_player_temp;
			
			//Reset
			score_computer_temp = 0;
			score_player_temp = 0;
				
			//Go to com choose phase
			global.current_phase = global.phase_card_to_fight_chosen;
				
		}
	break;
	
	case global.phase_card_to_fight_chosen:
		if(phase_result_timer > 0) phase_result_timer -= 1;
		else{
			phase_result_timer = phase_result_time;	
			
			//Move a card to the center for players to fight over
			audio_play_sound(snd_card, 1, false);
		
			var destination_x = room_width/2;
			var destination_y = room_height/2;
		
			global.main_card = deck[| ds_list_size(deck)-1];
			ds_list_delete(deck, ds_list_size(deck)-1);
		
			scr_move_card(global.main_card, destination_x, destination_y);
		
			global.main_card.face_up = true;
		
			global.current_phase = global.phase_computer_chooses;
		}
	break;
	
	case global.phase_computer_chooses:
		//CPU chooses a card to fight center card
		if(phase_result_timer > 0) phase_result_timer -= 1;
		else{
			phase_result_timer = phase_result_time;
			
			//Choose a card for computer if possible
			for(var i=0; i<ds_list_size(hand_computer); i++){
				var card = hand_computer[| i];
				
				if(card.kind >= global.main_card.kind){
					//Move card to center if it is playable
					playedcard_computer = card;

					var destination_x = room_width/2 - sprite_get_width(spr_card_back)*1.5;
					var destination_y = room_height/2;
			
					audio_play_sound(snd_card, 1, false);
					scr_move_card(card, destination_x, destination_y);
					
					ds_list_delete(hand_computer, i); //Delete card from computers hand
					break; //Stop looking for a card
				}
			}
			//Go to player choose phase
			global.current_phase = global.phase_player_chooses;
		}
		
	break;
	
	case global.phase_player_chooses:
		//When player is choosing a card
		var card = instance_position(mouse_x, mouse_y, obj_card);
		var is_valid_card = false;
		var player_has_cards = false;
		
		for(var i = 0; i < ds_list_size(hand_player); i++){
			//First make sure the player has a playable card
			var curr_card = hand_player[| i];
			if(curr_card.kind >= global.main_card.kind){
				player_has_cards = true;
				break;
			}
		}
		
		if(!player_has_cards){
			//If none of the player's cards are playable, move on
			global.current_phase = global.phase_result;
			break;
		}
		
		for(var i = 0; i < ds_list_size(hand_player); i++){
			//Make sure the card player is hovering is a player card
			var curr_card = hand_player[| i];
			if(curr_card == card) is_valid_card = true;
		}
		
		if(card != noone && is_valid_card){
			//Card hovers up
			card.hovering = true;
			global.move_speed = global.hover_move_speed;
			var destination_x = card.x;
			var destination_y = global.card_player_y - 20;
				
			card.curr_destination_x = destination_x;
			card.curr_destination_y = destination_y;
			card.moving = true;
			//instance_deactivate_object(object_index);
		}
		
		for(var i = 0; i < ds_list_size(hand_player); i++){
			//Hover cards back down
			var curr_card = hand_player[| i];
			if(curr_card.hovering && card != curr_card){
				var destination_x = curr_card.x;
				var destination_y = global.card_player_y;
				
				curr_card.curr_destination_x = destination_x;
				curr_card.curr_destination_y = destination_y;
				curr_card.moving = true;
				//instance_deactivate_object(object_index);
			
				curr_card.hovering = false;
			}
		}
		
		//Move clicked card toward center
		if(card != noone && is_valid_card && mouse_check_button_pressed(mb_left) && card.kind >= global.main_card.kind){
			audio_play_sound(snd_card, 1, false);
			
			for(var i=0; i<ds_list_size(hand_player); i++){
				//Delete card from player hand
				if(hand_player[| i] == card){
					ds_list_delete(hand_player, i);
					break;
				}
			}
			
			global.move_speed = global.card_move_speed;
			var destination_x = room_width/2 + sprite_get_width(spr_card_back)*1.5;
			var destination_y = room_height/2;
			playedcard_player = card;
				
			scr_move_card(card, destination_x, destination_y);
			
			//Go to player choose phase
			global.current_phase = global.phase_result;
		}
		
	break;
	
	case global.phase_result:
		//Show result after delay
		if(phase_result_timer > 0) phase_result_timer -= 1;
		else{
			phase_result_timer = phase_result_time_long;
			
			//Set values based on cards played and update scores 
			var value_player = 0;
			var value_computer = 0;
			if(playedcard_player != noone) value_player = playedcard_player.kind;
			if(playedcard_computer != noone){
				playedcard_computer.face_up = true;
				value_computer = playedcard_computer.kind;
			}
			global.score_player -= value_player;
			global.score_computer -= value_computer;
			
			//Calculate winner and distribute winnings
			if(value_player > value_computer){
				//Player wins. Put cards in player hand
				global.score_player += value_computer + global.main_card.kind;
				audio_play_sound(snd_win, 1, false);
				
				ds_list_add(player_get_pile, global.main_card);
				if(playedcard_computer != noone){ 
					ds_list_add(player_get_pile, playedcard_computer);
					ds_list_add(discard_pile, playedcard_player);
				}
				else ds_list_add(discard_pile, playedcard_player);
			}
			else if(value_player < value_computer){
				//Com wins. Put cards in com hand
				global.score_computer += value_player + global.main_card.kind;
				audio_play_sound(snd_lose, 1, false);
				
				ds_list_add(computer_get_pile, global.main_card);
				if(playedcard_player != noone){
					ds_list_add(computer_get_pile, playedcard_player);
					ds_list_add(discard_pile, playedcard_computer);
				}
				else ds_list_add(discard_pile, playedcard_computer);
			}
			else{
				//Tie and cards are put in discard
				audio_play_sound(snd_lose, 1, false);
				
				ds_list_add(discard_pile, global.main_card);
				if(playedcard_player != noone) ds_list_add(discard_pile, playedcard_player);
				if(playedcard_computer != noone) ds_list_add(discard_pile, playedcard_computer);
			}
			
			playedcard_computer = noone;
			playedcard_player = noone;
			global.current_phase = global.phase_discard;			
		}
	break;
	
	case global.phase_discard:
		//Discard cards that were not won
		
		if(phase_result_timer > 0){
			//Have pause for dramatic effect
			phase_result_timer -= 1;
		}
		else{
			//Pull from top of discard pile until gone
			if(!ds_list_empty(discard_pile)){
				var card = discard_pile[| ds_list_size(discard_pile)-1];
				ds_list_delete(discard_pile,  ds_list_size(discard_pile)-1);
				
				var destination_x = position_discard_x;
				var destination_y = position_discard_y - position_deck_y_mod;
				
				position_deck_y_mod += position_deck_y_mod_amount;
				card.depth = deck_depth;
				deck_depth -= 1;	
				
				audio_play_sound(snd_card, 1, false);
				scr_move_card(card, destination_x, destination_y);
				
			}
			else{
				phase_result_timer = phase_result_time;
				global.current_phase = global.phase_distribute;
			}
		}
		
		/* old code
		
		else if(playedcard_computer != noone){
			audio_play_sound(snd_card, 1, false);
			
			//COM card
			var destination_x = position_discard_x;
			var destination_y = position_discard_y - position_deck_y_mod;
			playedcard_computer.curr_destination_x = destination_x;
			playedcard_computer.curr_destination_y = destination_y;
			playedcard_computer.moving = true;
			instance_deactivate_object(object_index);
			position_deck_y_mod += position_deck_y_mod_amount;
			playedcard_computer.depth = deck_depth;
			deck_depth -= 1;
			
			ds_list_add(discard_pile, playedcard_computer);
			var curr_ind = 0;
			for(var i=0; i<ds_list_size(hand_computer); i++){
				var curr_card = hand_computer[| i];
				if(curr_card == playedcard_computer) curr_ind = i;
			}
			ds_list_delete(hand_computer, curr_ind); //Delete the played card from hand
			playedcard_computer = noone;
		}
		else if(playedcard_player != noone){
			audio_play_sound(snd_card, 1, false);
			
			//Player card
			var destination_x = position_discard_x;
			var destination_y = position_discard_y - position_deck_y_mod;
			playedcard_player.curr_destination_x = destination_x;
			playedcard_player.curr_destination_y = destination_y;
			playedcard_player.moving = true;
			instance_deactivate_object(object_index);
			position_deck_y_mod += position_deck_y_mod_amount;
			playedcard_player.depth = deck_depth;
			deck_depth -= 1;
			
			ds_list_add(discard_pile, playedcard_player);
			var curr_ind = 0;
			for(var i=0; i<ds_list_size(hand_player); i++){
				var curr_card = hand_player[| i];
				if(curr_card == playedcard_player) curr_ind = i;
			}
			ds_list_delete(hand_player, curr_ind); //Delete the played card from hand
			playedcard_player = noone;
		}
		else if(playedcard_computer == noone && playedcard_player == noone && !ds_list_empty(hand_computer)){
			audio_play_sound(snd_card, 1, false);
			
			//Every other card in computers hand
			var curr_com_card = hand_computer[| 0];
			
			curr_com_card.face_up = true;
			var destination_x = position_discard_x;
			var destination_y = position_discard_y - position_deck_y_mod;
			curr_com_card.curr_destination_x = destination_x;
			curr_com_card.curr_destination_y = destination_y;
			curr_com_card.moving = true;
			instance_deactivate_object(object_index);
			position_deck_y_mod += position_deck_y_mod_amount;
			curr_com_card.depth = deck_depth;
			deck_depth -= 1;
			
			ds_list_add(discard_pile, curr_com_card);
			ds_list_delete(hand_computer, 0);				
		}
		else if(playedcard_computer == noone && playedcard_player == noone && !ds_list_empty(hand_player)){
			audio_play_sound(snd_card, 1, false);
			
			//Every other card in players hand
			var curr_player_card = hand_player[| 0];
			
			var destination_x = position_discard_x;
			var destination_y = position_discard_y - position_deck_y_mod;
			curr_player_card.curr_destination_x = destination_x;
			curr_player_card.curr_destination_y = destination_y;
			curr_player_card.moving = true;
			instance_deactivate_object(object_index);
			position_deck_y_mod += position_deck_y_mod_amount;
			curr_player_card.depth = deck_depth;
			deck_depth -= 1;
			
			ds_list_add(discard_pile, curr_player_card);
			ds_list_delete(hand_player, 0);
		}
		else{
			//Move to next phase once all cards are placed in discard
			phase_result_timer = phase_result_time;
			
			if(!ds_list_empty(deck)){
				global.current_phase = global.phase_dealing;
			}
			else{ 
				position_deck_y_mod = 0;
				deck_depth = 0;
				global.current_phase = global.phase_reshuffle;
			}
		}
		*/
	break;
	
	case global.phase_distribute:
		//Put cards into player and CPU's hands respectively
		if(phase_result_timer > 0){
			//Have pause for dramatic effect
			phase_result_timer -= 1;
		}
		else{
			if(ds_list_size(computer_get_pile) > 0){
				//Pass cpu cards out if possible
				var card = computer_get_pile[| ds_list_size(computer_get_pile)-1];
				ds_list_delete(computer_get_pile, ds_list_size(computer_get_pile)-1);
				
				var destination_x = 0;
				var destination_y = global.card_com_y;
				
				for(var i = 0; i< array_length((global.card_x_positions)); i++){
					var x_to_check = global.card_x_positions[i];
					if(!instance_position(x_to_check, destination_y, obj_card)){
						//If there is no card at the coordinate, then move card to it
						destination_x = x_to_check;
						break;
					}
				}
				
				ds_list_add(hand_computer, card);
				
				audio_play_sound(snd_card, 1, false);
				scr_move_card(card, destination_x, destination_y);
				
				card.face_up = false;
			}
			else if(ds_list_size(player_get_pile) > 0){
				//Pass player cards out if possible
				var card = player_get_pile[| ds_list_size(player_get_pile)-1];
				ds_list_delete(player_get_pile, ds_list_size(player_get_pile)-1);
				
				var destination_x = 0;
				var destination_y = global.card_player_y;
				
				for(var i = 0; i< array_length((global.card_x_positions)); i++){
					var x_to_check = global.card_x_positions[i];
					if(!instance_position(x_to_check, destination_y, obj_card)){
						//If there is no card at the coordinate, then move card to it
						destination_x = x_to_check;
						break;
					}
				}
				
				ds_list_add(hand_player, card);
				
				audio_play_sound(snd_card, 1, false);
				scr_move_card(card, destination_x, destination_y);		
			}
			else{
				phase_result_timer = phase_result_time;
				global.current_turn += 1;
				if(global.current_turn <= global.number_turns){
					global.current_phase = global.phase_card_to_fight_chosen;
				}
				else{
					//End the game and determine a winner
					room_goto(rm_victory);
				}
			}
		}
		
		/*
		//Restack and shuffle cards
		global.move_speed = global.card_stack_speed;
		if(!ds_list_empty(discard_pile)){
			audio_play_sound(snd_card, 1, false);
			
			//Restack cards into deck
			var top_card = discard_pile[| ds_list_size(discard_pile)-1]
			
			top_card.face_up = false;
			var destination_x = position_deck_x;
			var destination_y = position_deck_y - position_deck_y_mod;
			top_card.curr_destination_x = destination_x;
			top_card.curr_destination_y = destination_y;
			top_card.moving = true;
			instance_deactivate_object(object_index);
			
			position_deck_y_mod += position_deck_y_mod_amount;
			top_card.depth = deck_depth;
			deck_depth -= 1;
			
			ds_list_add(deck, top_card);
			ds_list_delete(discard_pile, ds_list_size(discard_pile)-1);
		}
		else if(ds_list_empty(discard_pile) && shuffled_number < amount_to_shuffle){
			//Shuffle deck by actually moving around cards
			audio_play_sound(snd_card, 1, false);
			global.move_speed = global.hover_move_speed;
			
			shuffled_number += 1;
			
			var random_card_ind = irandom_range(0, ds_list_size(deck)-1);
			var random_card = deck[| random_card_ind];
			var top_card = deck[| ds_list_size(deck) - 1];
			var top_y = top_card.y;
			var top_depth = top_card.depth;
			
			
			var destination_x = position_deck_x;
			var destination_y = top_y;
			random_card.curr_destination_x = destination_x;
			random_card.curr_destination_y = destination_y;
			random_card.moving = true;
			instance_deactivate_object(object_index);
			
			random_card.depth = top_depth+1;
			random_card.y = top_y+position_deck_y_mod_amount;
			
			ds_list_delete(deck, random_card_ind);
			ds_list_add(deck, random_card);

		}
		else if(shuffled_number == amount_to_shuffle){
			deck_depth = 0;
			position_deck_y_mod = 0;
			shuffled_number = 0;
			ds_list_clear(hand_computer);
			ds_list_clear(hand_player);
			
			//Clean up deck appearance
			for(var i = 0; i < deck_size; i++){
				var curr_card = deck[| i];
				curr_card.x = position_deck_x;
				curr_card.y = position_deck_y - position_deck_y_mod;
				curr_card.depth = deck_depth;
				deck_depth -= 1;
	
				//Adjust modifier
				position_deck_y_mod += position_deck_y_mod_amount;
			}
			position_deck_y_mod = 0;
			deck_depth = 0;
			
			global.move_speed = global.card_move_speed;
			global.current_phase = global.phase_dealing;
		}
		*/
	break;
}