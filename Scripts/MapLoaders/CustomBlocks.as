
//namespace CMap
//{
//	enum CustomTiles
//	{
//		tile_whatever = 300
//	};
//};

const SColor color_spawnpoint(255, 0, 0, 255);

const SColor color_dirtcornersmall(255, 70, 25, 10);
const SColor color_stonecornersmall(255, 80, 80, 80);

//const SColor color_waypoint(255, 0, 215, 215);
const SColor color_waypoint_noup(255, 0, 200, 100);

// wall guns
const SColor color_pistol(255, 1, 0, 0);
const SColor color_chiron(255, 2, 0, 0);
const SColor color_revolver(255, 3, 0, 0);
const SColor color_olympia(255, 4, 0, 0);
const SColor color_pumpaction(255, 5, 0, 0);
//const SColor color_automaticrifle(255, 2, 0, 0);
//const SColor color_submachinegun(255, 3, 0, 0);
//const SColor color_rifle(255, 5, 0, 0);

//perk machines
const SColor color_juggernog(255, 30, 0, 0);
const SColor color_doubletap(255, 31, 0, 0);
const SColor color_speedycola(255, 32, 0, 0);
const SColor color_staminup(255, 33, 0, 0);
//const SColor color_quickrevive(255, 34, 0, 0);
//const SColor color_phdflopper(255, 35, 0, 0);
const SColor color_packapunch(255, 120, 120, 0);
const SColor color_mysterybox(255, 120, 0, 120);

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	
	//u8 alpha = pixel.getAlpha();

	//if(alpha < 255) // < why this?
	//{
	//	SColor rgb = SColor(0xFF, pixel.getRed(), pixel.getGreen(), pixel.getBlue());
	//	if (rgb == color_waypoint) 
	//	{			
	//		u16 num = (alpha-100);			
	//		AddMarker( map, offset, "waypoint"+num);
	//		print("waypoint"+num);
	//		map.SetTile(offset, CMap::tile_castle_back);
	//	}
	//}

	if(pixel == color_spawnpoint)
	{
		map.SetTile(offset, CMap::tile_castle_back);
		CBlob@ b = server_CreateBlob("spawnpoint", 0, getMap().getTileWorldPosition(offset));
		if (b !is null)
		{			
			b.getShape().SetStatic( true );
		}
	}
	// wall guns
	else if(pixel == color_pistol)
	{
		map.SetTile(offset, CMap::tile_castle_back);
		CBlob@ b = server_CreateBlob("pistolshop", -1, getMap().getTileWorldPosition(offset)+Vec2f(4,4));
		if (b !is null)
		{			
			b.getShape().SetStatic( true );
		}
	}
	else if(pixel == color_revolver)
	{
		map.SetTile(offset, CMap::tile_castle_back);
		CBlob@ b = server_CreateBlob("revolvershop", -1, getMap().getTileWorldPosition(offset)+Vec2f(4,4));
		if (b !is null)
		{			
			b.getShape().SetStatic( true );
		}
	}
	else if(pixel == color_olympia)
	{
		map.SetTile(offset, CMap::tile_castle_back);
		CBlob@ b = server_CreateBlob("olympiashop", -1, getMap().getTileWorldPosition(offset)+Vec2f(4,4));
		if (b !is null)
		{			
			b.getShape().SetStatic( true );
		}
	}
	else if(pixel == color_pumpaction)
	{
		map.SetTile(offset, CMap::tile_castle_back);
		CBlob@ b = server_CreateBlob("pumpactionshop", -1, getMap().getTileWorldPosition(offset)+Vec2f(4,4));
		if (b !is null)
		{			
			b.getShape().SetStatic( true );
		}
	}


	//perk machines
	else if(pixel == color_juggernog)
	{
		map.SetTile(offset, CMap::tile_castle_back);
		CBlob@ b = server_CreateBlob("perkmachine", 1, getMap().getTileWorldPosition(offset)+Vec2f(4,4));
		if (b !is null)
		{			
			b.set_u8("type", 0);
			b.getShape().SetStatic( true );
		}
	}
	else if(pixel == color_doubletap)
	{
		map.SetTile(offset, CMap::tile_castle_back);
		CBlob@ b = server_CreateBlob("perkmachine", 4, getMap().getTileWorldPosition(offset)+Vec2f(4,4));
		if (b !is null)
		{			
			b.set_u8("type", 1);
			b.getShape().SetStatic( true );
		}
	}
	else if(pixel == color_speedycola)
	{
		map.SetTile(offset, CMap::tile_castle_back);
		CBlob@ b = server_CreateBlob("perkmachine", 2, getMap().getTileWorldPosition(offset)+Vec2f(4,4));
		if (b !is null)
		{			
			b.set_u8("type", 2);
			b.getShape().SetStatic( true );
		}
	}
	else if(pixel == color_mysterybox)
	{
		map.SetTile(offset, CMap::tile_castle_back);
		CBlob@ b = server_CreateBlob("mysterybox", 0, getMap().getTileWorldPosition(offset)+Vec2f(4,4));
		if (b !is null)
		{			
			b.getShape().SetStatic( true );
		}
	}

}