//Set sprite for front of card
if(kind == 1){
	sprite_front = spr_card_1;
}
else if(kind == 2){
	sprite_front = spr_card_2;
}
else if(kind == 3){
	sprite_front = spr_card_3;
}
else if(kind == 4){
	sprite_front = spr_card_4;
}
else if(kind == 5){
	sprite_front = spr_card_5;
}
else if(kind == 6){
	sprite_front = spr_card_6;
}
else if(kind == 7){
	sprite_front = spr_card_7;
}
else if(kind == 8){
	sprite_front = spr_card_8;
}
else if(kind == 9){
	sprite_front = spr_card_9;
}

//Adjust sprite depending on face up or down
if(face_up){
	sprite_index = sprite_front;
}
else{
	sprite_index = sprite_back;
}

//Move card to its designated location
if(moving && curr_destination_x != noone && curr_destination_y != noone){
	//show_debug_message(curr_destination_x)
	//show_debug_message(curr_destination_y)
	
	if(point_distance(x, y, curr_destination_x, curr_destination_y) > global.move_speed){
		move_towards_point(curr_destination_x,  curr_destination_y, global.move_speed);
	}
	else{
		x = curr_destination_x;
		y = curr_destination_y;
		curr_destination_x = noone;
		curr_destination_y = noone;
		speed = 0;
		moving = false;
		instance_activate_object(obj_dealer); //Start dealer again
	}
}
