gpu_set_texfilter(false);

//Temporary Score Variables so players can't tell what cards are dealt
score_computer_temp = 0;
score_player_temp = 0;

//Turn variables
global.current_turn = 1;
global.number_turns = 7;

//Main Card players fight over
global.main_card = noone;

//Enumerator for card types
global.rock = 0;
global.paper = 1;
global.scissors = 2;

//Game phases
global.phase_dealing = 0;
global.phase_card_to_fight_chosen = 1;
global.phase_computer_chooses = 2;
global.phase_player_chooses = 3;
global.phase_distribute = 4;
global.phase_result = 5;
global.phase_discard = 6;
global.phase_reshuffle = 7;
global.current_phase = global.phase_dealing;
phase_result_timer = room_speed * .5;
phase_result_time = room_speed * .5;
phase_result_time_long = room_speed * 1.5;

//Animation
global.move_speed = 20;
global.hover_move_speed = 1;
global.card_move_speed = 20;
global.card_stack_speed = 60;

//Game tracking
playedcard_player = noone;
playedcard_computer = noone;

//Deck variables
deck_size = 36;
hand_size = 6;
deck = ds_list_create();
hand_player = ds_list_create();
hand_computer = ds_list_create();
discard_pile = ds_list_create();
player_get_pile = ds_list_create();
computer_get_pile = ds_list_create();

//Positioning 
position_deck_x = sprite_get_width(spr_card_back); 
position_deck_y = room_height/2; 
position_deck_y_mod = 0; //Modifier for cards to stack
position_deck_y_mod_amount = 2; //Value for modifier

position_discard_x = room_width - sprite_get_width(spr_card_back);
position_discard_y = room_height/2; 
position_discard_y_mod = 0; //Modifier for cards to stack
position_discard_y_mod_amount = 2; //Value for modifier

//Shuffling
shuffled_number = 0;
amount_to_shuffle = deck_size * 2;

//Positioning cards
global.card_com_y = 0 + (room_height/8);
global.card_player_y = room_height - (room_height/8);

global.card_x_positions = [(room_width/2) - 3.5*((room_width/2)/5),
						(room_width/2) - 3.5*((room_width/2)/5) + sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 2*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 3*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 4*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 5*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 6*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 7*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 8*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 9*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 10*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 11*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 12*sprite_get_width(spr_card_back),
						(room_width/2) - 3.5*((room_width/2)/5) + 13*sprite_get_width(spr_card_back),
						]; 

global.card_is_moving = false;
global.curr_moving_card_num = 1;
curr_card_number = 1;

//Setup our deck of cards, of size deck_size
for(var i = 0; i < deck_size; i++){
	var new_card = instance_create_layer(0, 0, "Instances", obj_card);
	
	new_card.is_dealt = false;
	new_card.face_up = false;
	
	new_card.kind = (i mod 9) + 1;
	
	//Add the new card to the deck list
	ds_list_add(deck, new_card);
}

//Shuffle the deck
randomize();
ds_list_shuffle(deck);



//For the first set of cards in each hand, no cards should show up more than twice
var cards_in_hand = ds_map_create();
for(var i = 0; i < hand_size; i++){
	//CPU's hand
	var curr_ind = deck_size-i-1;
	var curr_card = deck[| curr_ind];
	if(!ds_map_exists(cards_in_hand, curr_card.kind)){
		ds_map_add(cards_in_hand, curr_card.kind, 1);
	}
	else if(ds_map_exists(cards_in_hand, curr_card.kind) && cards_in_hand[| curr_card.kind] == 1){
		cards_in_hand[| curr_card.kind] += 1;
	}
	else if(ds_map_exists(cards_in_hand, curr_card.kind) && cards_in_hand[| curr_card.kind] >= 2){
		//Swap card for a valid one
		//Keep looking for random cards until you get one that is not a repeat
		var invalid = true;
		var random_ind = noone;
		while(invalid){
			//Find a valid random card
			random_ind = irandom_range(hand_size*2, deck_size-1);
			var card_to_check = deck[| random_ind];
			if(card_to_check.kind != curr_card.kind){
				if(!ds_map_exists(cards_in_hand, card_to_check.kind)){
					invalid = false;
					ds_map_add(cards_in_hand, card_to_check.kind, 1);
				}
				else if(ds_map_exists(cards_in_hand, card_to_check.kind) && cards_in_hand[| card_to_check.kind] < 2){
					invalid = false;
					cards_in_hand[| card_to_check.kind] += 1;
				}
			}
		}
		deck[| curr_ind] = deck[| random_ind];
		deck[| random_ind] = curr_card;
	}
}

ds_map_clear(cards_in_hand);

for(var i = hand_size; i < hand_size*2; i++){
	//Player's hand
	var curr_ind = deck_size-i-1;
	var curr_card = deck[| curr_ind];
	if(!ds_map_exists(cards_in_hand, curr_card.kind)){
		ds_map_add(cards_in_hand, curr_card.kind, 1);
	}
	else if(ds_map_exists(cards_in_hand, curr_card.kind) && cards_in_hand[| curr_card.kind] == 1){
		cards_in_hand[| curr_card.kind] += 1;
	}
	else if(ds_map_exists(cards_in_hand, curr_card.kind) && cards_in_hand[| curr_card.kind] >= 2){
		//Swap card for a valid one
		//Keep looking for random cards until you get one that is not a repeat
		var invalid = true;
		var random_ind = noone;
		while(invalid){
			//Find a valid random card
			random_ind = irandom_range(hand_size*2, deck_size-1);
			var card_to_check = deck[| random_ind];
			if(card_to_check.kind != curr_card.kind){
				if(!ds_map_exists(cards_in_hand, card_to_check.kind)){
					invalid = false;
					ds_map_add(cards_in_hand, card_to_check.kind, 1);
				}
				else if(ds_map_exists(cards_in_hand, card_to_check.kind) && cards_in_hand[| card_to_check.kind] < 2){
					invalid = false;
					cards_in_hand[| card_to_check.kind] += 1;
				}
			}
		}
		deck[| curr_ind] = deck[| random_ind];
		deck[| random_ind] = curr_card;
	}
}

ds_map_clear(cards_in_hand);


//Stack cards
deck_depth = 0;
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