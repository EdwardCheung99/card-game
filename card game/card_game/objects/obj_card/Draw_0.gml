draw_self();

//Draw card number
draw_set_font(fnt_score);
if(sprite_index == sprite_front){
	draw_set_valign(fa_left);
	draw_set_halign(fa_left);
	draw_text(x-sprite_get_width(spr_card_back)/2+5, y-sprite_get_height(spr_card_back)/2, kind);
	
	draw_set_halign(fa_right);
	draw_set_valign(fa_right);
	draw_text(x+sprite_get_width(spr_card_back)/2-5, y+sprite_get_height(spr_card_back)/2, kind);
}

draw_set_halign(fa_left);
draw_set_valign(fa_left);