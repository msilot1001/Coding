
local root = script.Parent

local data = {
	animations = {
	
		viewmodel = {
			idle = root.animations.idle;
			fire = root.animations.fire;
			reload = root.animations.reload;
		};
	
		player = {
			aim = root.serverAnimations.aim;
			aimFire = root.serverAnimations.aimFire;
			idle = root.serverAnimations.idle;
			idleFire = root.serverAnimations.idleFire;
		};
	
	};
	
	firing = {
		
		damage = 25;
		headshot = 50;
		rpm = 700;
		magCapacity = 30;
		velocity = 1500;
		range = 5000;
	}
	
}

return data