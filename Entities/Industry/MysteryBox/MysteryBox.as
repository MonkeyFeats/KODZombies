
u8 opentime;
u8 gunframe;
bool isopen;
bool ready;
u16 callerId;

 Random _r(0xa7c3a);

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	this.RemoveSpriteLayer("lid");
	CSpriteLayer@ lid = this.addSpriteLayer("lid", "MysteryBox.png", 48, 16);
	if (lid !is null)
	{
		Animation@ anim = lid.addAnimation("default", 0, false);
		anim.AddFrame(1);

		Animation@ open = lid.addAnimation("open", 4, false);
		int[] openframes = {1, 2, 3, 4, 5};
		open.AddFrames(openframes);

		Animation@ close = lid.addAnimation("close", 4, false);
		int[] closeframes = {5, 4, 3, 2, 1};
		close.AddFrames(closeframes);

		lid.SetAnimation("default");
		lid.SetOffset(Vec2f(0, -3));
		lid.SetVisible(true);
		lid.SetRelativeZ(1.0f);
	}

	// add shiny
	this.RemoveSpriteLayer("gun");
	CSpriteLayer@ gun = this.addSpriteLayer("gun", "Weapons.png", 32, 16);
	if (gun !is null)
	{
		Animation@ anim = gun.addAnimation("default", 0, false);
		int[] weapons = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
		anim.AddFrames(weapons);

		gun.SetAnimation("default");
		gun.SetOffset(Vec2f(0, -3));
		gun.SetRelativeZ(2.0f);
		gun.SetVisible(false);
		gun.SetLighting(false); // self lit
		//gun.ScaleBy(Vec2f(0.75f, 0.75f));
		//gun.setRenderStyle(RenderStyle::outline);
	}
}

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 15;

	this.addCommandID("open");
	this.addCommandID("close");
	this.addCommandID("take");

	isopen = false;
	opentime = 0;

	this.SetLight(false);
	this.SetLightRadius(40.0f);
	this.SetLightColor(SColor(255,240,230,180));
}

void onTick(CBlob@ this)
{
	if (!isopen) return;
	opentime++;

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ gunlayer = sprite.getSpriteLayer("gun");			
	if (gunlayer !is null)
	{
		if (opentime > 1 && opentime < 13)
		{
			gunlayer.SetVisible(true);
			Animation@ anim = gunlayer.getAnimation("default");	
			gunframe = _r.NextRanged(anim.getFramesCount());
			gunlayer.SetFrameIndex(  gunframe  );	
		}

		if (opentime == 13)
		{
			ready = true;
		}

		if (opentime == 25)
		{			
			CBitStream params;
			this.SendCommand(this.getCommandID("close"), params);
		}		
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// button for runner
	// create menu for class change

	if (this.isOverlapping(caller) && !isopen)
	{	
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton("$trade$", Vec2f_zero, this, this.getCommandID("open"), getTranslatedString("Buy \n 200"), params);

		button.radius = 18.0f;
		button.enableRadius = 18.0f;
	}

	if (this.isOverlapping(caller) && ready && callerId == caller.getNetworkID())
	{	
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u8(gunframe);
		CButton@ button = caller.CreateGenericButton("$trade$", Vec2f_zero, this, this.getCommandID("take"), getTranslatedString("Take"), params);

		button.radius = 18.0f;
		button.enableRadius = 18.0f;
	}

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{	
	if (cmd == this.getCommandID("open"))
	{		
		callerId = params.read_u16();
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		openbox(this, caller);
	}
	else if (cmd == this.getCommandID("close"))
	{
		closebox(this);
	}
	else if (cmd == this.getCommandID("take"))
	{
		//closebox(this);
	}

}

void openbox(CBlob@ this, CBlob@ caller)
{
	CSprite@ sprite = this.getSprite();	
	sprite.getSpriteLayer("lid").SetAnimation("open");
	sprite.PlaySound("MysteryBoxOpenAndChime.ogg");

	this.SetLight(true);	

	isopen = true;	
}

void closebox(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();	
	sprite.getSpriteLayer("lid").SetAnimation("close");	
	sprite.getSpriteLayer("gun").SetVisible(false);
	sprite.PlaySound("MysteryBoxClose.ogg");

	this.SetLight(false);

	isopen = false;
	opentime = 0;
	ready = false;
}