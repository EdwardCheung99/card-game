function scr_move_card(card, destination_x, destination_y){			
	card.curr_destination_x = destination_x;
	card.curr_destination_y = destination_y;
	card.moving = true;
				
	//Stop dealer until animation finishes
	instance_deactivate_object(object_index); 
	
	return;
}