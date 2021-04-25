//Position Variables
score_com_x = sprite_get_width(spr_card_back)/5;
score_com_y = (sprite_get_height(spr_card_back)/3)/2;
score_player_x = sprite_get_width(spr_card_back)/5;
score_player_y = room_height - sprite_get_height(spr_card_back)/3;

turn_x = room_width/2;
turn_y = room_height/2 - sprite_get_height(spr_card_back);

//Score
global.score_player = 0;
global.score_computer = 0;