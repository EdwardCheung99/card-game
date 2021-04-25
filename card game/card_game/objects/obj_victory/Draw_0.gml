//Show Winner
draw_set_font(fnt_result);
draw_set_halign(fa_center);
draw_set_valign(fa_center);

if(global.score_computer > global.score_player){
	draw_set_color(c_red);
	draw_text(result_x, result_y, "YOU LOSE");
}
else if(global.score_computer < global.score_player){
	draw_set_color(c_green);
	draw_text(result_x, result_y, "YOU WIN");
}
else{
	draw_set_color(c_fuchsia);
	draw_text(result_x, result_y, "Draw");
}

draw_set_font(fnt_score);
draw_set_color(c_white);
draw_text(restart_x, restart_y, "Press Space to Play Again.");

if(keyboard_check_released(vk_space)){
	draw_set_halign(fa_left);
	draw_set_valign(fa_left);
	room_goto(rm_main);
}