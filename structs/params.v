module structs

import gx
import ui

pub struct Btn_style {
	pub mut:
	radius int = 5
	bg_color gx.Color = gx.Color{r: 106, g: 90, b: 205}
	border_color gx.Color = gx.Color{}
	bg_color_pressed gx.Color = gx.Color{r: 106, g: 90, b: 255}
	bg_color_hover gx.Color = gx.Color{r: 106, g: 90, b: 235}
	text_font_name string
	text_color gx.Color = gx.color_from_string('white')
	text_size int
}

pub struct Btn_params {
	pub mut:
	id string
	text string
	width int
	height int
	style Btn_style
	on_click fn(&ui.Button)
}
