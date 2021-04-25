//Draw Score
draw_set_font(fnt_score);
draw_text(score_com_x, score_com_y, "CPU: "+ string(global.score_computer));
draw_text(score_player_x, score_player_y, "You: " + string(global.score_player));

//Draw turn
draw_set_halign(fa_center);
draw_text(turn_x, turn_y, "Turn: " + string(global.current_turn) + "/7");
draw_set_halign(fa_left);