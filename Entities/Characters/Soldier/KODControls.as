// Standard menu player controls

#include "EmotesCommon.as"
#include "StandardControlsCommon.as"

void onInit(CBlob@ this)
{
	this.set_s32("tap_time", getGameTime());
	this.set_u16("hover netid", 0);
	this.set_bool("release click", false);
	this.set_bool("can button tap", true);	
}

void onTick(CBlob@ this)
{	
	// use menu
	if (this.isKeyJustPressed(key_use))
	{
		Tap(this);
		this.set_bool("can button tap", !getHUD().hasMenus());
		this.ClearMenus();
		this.ShowInteractButtons();
		this.set_bool("release click", true);
	}
	else if (this.isKeyJustReleased(key_use))
	{
		if (this.get_bool("release click"))
		{
			ButtonOrMenuClick(this, this.getPosition(), true, isTap(this) && this.get_bool("can button tap"));
		}

		this.ClearButtons();
	}

	if (this.isKeyJustPressed(key_bubbles))
	{
		this.CreateBubbleMenu();
		Tap(this);
	}

	if (getHUD().hasButtons())
	{
		if ((this.isKeyJustPressed(key_action1) /*|| getControls().isKeyJustPressed(KEY_LBUTTON)*/) && !this.isKeyPressed(key_pickup))
		{
			ButtonOrMenuClick(this, this.getAimPos(), false, true);
			this.set_bool("release click", false);
		}
	}
}

bool ClickGridMenu(CBlob@ this, int button)
{
	CGridMenu @gmenu;
	CGridButton @gbutton;

	if (this.ClickGridMenu(button, gmenu, gbutton))   // button gets pressed here - thing get picked up
	{
		if (gmenu !is null)
		{
			return true;
		}
	}

	return false;
}

void ButtonOrMenuClick(CBlob@ this, Vec2f pos, bool clear, bool doClosestClick)
{
	if (!ClickGridMenu(this, 0))
		if (this.ClickInteractButton())
		{
			clear = false;
		}
		else if (doClosestClick)
		{
			if (this.ClickClosestInteractButton(pos, this.getRadius() * 1.0f))
			{
				this.ClearButtons();
				clear = false;
			}
		}

	if (clear)
	{
		this.ClearButtons();
		this.ClearMenus();
	}
}

//void onRender(CSprite@ this)
//{
//	GUI::DrawText("Buy", this.getBlob().getPosition(), SColor(180,255,255,255));
//}

// show dots on chat
void onDie(CBlob@ this)
{
	set_emote(this, Emotes::off);
}