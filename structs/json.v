module structs

pub struct Profile {
	pub mut:
	name string
	src string
	target string
}
pub struct Profiles {
	pub mut:
	profiles []Profile
}
