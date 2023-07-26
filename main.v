module main

import ui { button, row, column, Button }
import os { create, read_file, write_file, mv }
import json
import structs { Profiles, Btn_params, Btn_style, Profile }
import gx

struct App {
	mut:
		width int = 600
		// height int = 600
		window     &ui.Window = unsafe { nil }
		profile string = 'None selected'
		profile_chosen bool
		src string
		target string
}

fn btn(params Btn_params) Button {
	return Button{
		id: params.id
		text: params.text
		width: params.width
		// height: params.height
		on_click: params.on_click
		hoverable: true
		style_params: ui.ButtonStyleParams{
			radius: params.style.radius
			border_color: params.style.border_color
			bg_color: params.style.bg_color
			bg_color_pressed: params.style.bg_color_pressed
			bg_color_hover: params.style.bg_color_hover
			text_font_name: params.style.text_font_name
			text_color: params.style.text_color
			text_size: params.style.text_size
			text_align: ui.TextHorizontalAlign.center
			text_vertical_align: ui.TextVerticalAlign.middle
		}
	}
}

fn sync_contents(it &ui.Button, mut app &App) {
	if app.profile_chosen {
		it.ui.window.get_or_panic[ui.Label]('show_error').text = ''
		mv(app.src, app.target) or {
			it.ui.window.get_or_panic[ui.Label]('show_error').text = 'Error: Either src or target does not exist'
			it.ui.window.get_or_panic[ui.Label]('confirmation_label').text = ''
		}
		it.ui.window.get_or_panic[ui.Label]('confirmation_label').text = 'Process finished successfully'
	}else {
		it.ui.window.get_or_panic[ui.Label]('show_error').text = 'Error: No profile was selected'
		it.ui.window.get_or_panic[ui.Label]('confirmation_label').text = ''
	}

}

fn get_from_file(file string)  Profiles{
	mut profiles := read_file(file) or {
		create(file) or {
			panic('File config could not be created')
		}
		panic('Creating the profile file configuration...\n')
	}
	if profiles.len == 0 {
		write_file(file, '{}') or {
			panic('Configuration file not found')
		}
		profiles = read_file(file) or { panic('file not found') }
	}
	structured_profiles := json.decode(Profiles, profiles) or {
		panic('Could not convert')
	}
	return structured_profiles
}

fn create_profiles(mut app &App) []ui.Widget {
	file := './profiles.json'
	structured_profiles := get_from_file(file)
	mut result_profiles := []ui.Widget{}

	for profile in structured_profiles.profiles {
		result_profiles << row(
			id: '${profile.name}_row'
			width: app.width,
			children: [
				column(
					width: app.width,
					margin: ui.Margin{
						top: 10
						bottom: 10
					}
					children: [
						ui.label(
							width: app.width
							text: profile.name
						),
						btn(
							Btn_params{
								id: '${profile.name}_choose'
								text: 'Choose profile'
								on_click: fn [mut app, profile] (it &ui.Button) { choose_profile(it, mut &app, profile)}
							}
						),
						btn(
								Btn_params{
								id: '${profile.name}_remove'
								text: 'Remove profile'
								style: Btn_style{
									bg_color: gx.Color{
										r: 210
										g: 100
										b: 102
									}
									bg_color_hover: gx.Color{
										r: 210
										g: 100
										b: 102
									}
									text_color: gx.color_from_string('white')
								}
								on_click: fn [mut app] (mut it &ui.Button) {
									remove_profile(mut it, mut app)
								}
							}
						)
					]
				)
			]
		)
	}

	result_profiles << btn(
			Btn_params{
			id: 'sync_data'
			text: 'Sync'
			style: Btn_style{
				bg_color: gx.Color{
					r: 47
					g: 87
					b: 47
				}
				bg_color_hover: gx.Color{
					r: 47
					g: 87
					b: 47
				}
				text_color: gx.color_from_string('white')
			}
			on_click: fn [mut app] (it &ui.Button) {
				sync_contents(it, mut app)
			}
		}
	)
	result_profiles << ui.label(
		id: 'show_error',
		text:  '',
		text_color: gx.color_from_string('red')
	)
	result_profiles << ui.label(
		id: 'src_label',
		text:  ''
	)
	result_profiles << ui.label(
		id: 'target_label',
		text:  ''
	)
	result_profiles << ui.label(
		id: 'confirmation_label',
		text:  '',
		text_color: gx.Color{
			r: 72
			g: 161
			b: 77
		}
	)
	return result_profiles
}

fn choose_profile (it &ui.Button, mut app &App, profile Profile) {
	mut new_split := it.id.split('_')
	app.profile = new_split.join('_')
	app.src = profile.src
	app.target = profile.target
	app.profile_chosen = true

	it.ui.window.get_or_panic[ui.Label]('show_error').text = ''
	it.ui.window.get_or_panic[ui.Label]('confirmation_label').text = ''
	it.ui.window.get_or_panic[ui.Label]('src_label').text = 'Src: ${app.src}'
	it.ui.window.get_or_panic[ui.Label]('target_label').text = 'Target: ${app.target}'
}

fn remove_profile(mut it &ui.Button, mut app &App) {
	mut new_split := it.id.split('_')
	new_split.pop()
	aux := new_split.join('_')

	file := './profiles.json'

	mut structured_profiles := get_from_file(file)
	mut new_profiles := []Profile{}
	for x in structured_profiles.profiles {
		if aux != x.name{
			new_profiles << x
		}
	}
	new_json := json.encode(Profiles{profiles: new_profiles})
	write_file(file, new_json) or { it.ui.window.get_or_panic[ui.Label]('show_error').text = 'Error: Could not find configuration file' }

	ui.message_box('Reset the aplication to apply the new configuration')
}

fn main() {
	mut app := &App{}
	app.window = ui.window(
		width: app.width,
		// height: app.height
		title: 'Directory Sync',
		children: [
			ui.column(
				id: 'main_wrap'
				margin: ui.Margin{5, 5, 5, 5}
				children: create_profiles(mut app)
			),
		]
	)
	ui.run(app.window)
}
