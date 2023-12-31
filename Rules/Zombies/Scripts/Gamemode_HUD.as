//KODZombies Gamemode HUD

void onInit( CRules@ this )
{
	if (!GUI::isFontLoaded("BloodLust"))
	{		
		string AveriaSerif = CFileMatcher("BloodLust.ttf").getFirst();
		GUI::LoadFont("BloodLust", AveriaSerif, 44, true);
	}
}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	GUI::SetFont("BloodLust");
	
	const f32 HUD_Y = getScreenHeight();
	const u8 round = this.get_u8("round");
	u8 timer = this.get_u8("intermission timer");
	u8 amount = 150 * Maths::Sin(Maths::Pi*2.0f*(timer)/40);
	SColor col = SColor(255,200, 50+amount, 50+amount);

	GUI::DrawText( ""+round, Vec2f(16,HUD_Y-64), col );
}
