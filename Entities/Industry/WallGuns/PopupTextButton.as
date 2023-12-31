
void onRender(CSprite@ this)
{
	CBlob@ thisBlob = this.getBlob();

	CBlob@[] blobsInRadius;
	if (getMap().getBlobsInRadius(thisBlob.getPosition(), thisBlob.getRadius(), @blobsInRadius))
	{
		for ( uint i = 0; i < blobsInRadius.size(); i++ )
		{
			CBlob @b = blobsInRadius[i];
			PopupTextButton@ button;
			if (b.get("buttonInfo", @button))
			{
				button.Render();

				if (thisBlob.isKeyJustPressed( key_use ))
				{
					CBitStream params;
					params.write_u8( button.CustomData );
					thisBlob.SendCommand( thisBlob.getCommandID("buy"), params);
				}

				break;
			}
		}
	}
}

enum GunType 
{
	Pistol = 0,
	Revolver = 1,
	Olympia = 2,
	Sniper = 3
}

shared class PopupTextButton
{
	CBlob@ OwnerBlob;
	string Text;
	string ActivationText;
	SColor Color;
	Vec2f Position;
	u8 CustomData;

	PopupTextButton(CBlob@ _b, string _text, string _actText, Vec2f _pos, SColor _col, u8 _data)
	{
		@OwnerBlob = _b;
		Text = _text;
		ActivationText = _actText;
		Position = _pos;
		Color = _col;
		CustomData = _data;
	}

	void Render()
	{
		//string usekeyname = getControls().getActionKeyKeyName(AK_USE);
		GUI::SetFont("menu");
		GUI::DrawTextCentered(this.Text, getDriver().getScreenPosFromWorldPos(this.Position), this.Color);
		GUI::DrawTextCentered(this.ActivationText, getDriver().getScreenPosFromWorldPos(this.Position+Vec2f(0, 6)), this.Color);
	}
}