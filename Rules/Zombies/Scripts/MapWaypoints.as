#define SERVER_ONLY

shared class Node
{	
	Path@[] PathTo;
	u16 ID;
	Vec2f Position;
	u16[] ConnectionsIDs;

	Node(u16 _id, ConfigFile cfg) 
	{
		ID = _id;		

		Vec2f pos; getMap().getMarker("waypoint_"+_id, pos );
		Position = pos;

		u16[] connections;
		connections.clear();
		cfg.readIntoArray_u16(connections, "nodeConnections_"+_id);

		ConnectionsIDs = connections;

		//PathTo[i].Nodes.push_back(this);	
	}
}

shared class Path // from one node to another
{
	Node@[] Nodes;
	f32 Length;

	Path(){}

	Path(Node@[] nodes, f32 leng)
	{
		Nodes = nodes;
		Length = leng;
	}

	void Render()
	{
		for(int i = 0; i < Nodes.size()-1; i++)		
			GUI::DrawArrow(Nodes[i].Position, Nodes[i+1].Position, SColor(255,255,0,255));
	}
}

shared class MapWaypoints
{
	Node@[] allNodes;	

	MapWaypoints()
	{
		ConfigFile cfg;
		if (cfg.loadFile("TowerofGod.cfg"))
		{
			u16[][] orderedNodesnums;


			for (u16 i = 0; i < 154; i++) // 154 max possible waypoint count
			{				
				if (getMap().hasMarker("waypoint_"+i))				
				{		
					Node node( i, cfg);
					if (node !is null)
					{
						allNodes.push_back(node);							

						u16[] orderedNeighbours;
						for (u16 j = 0; j < allNodes[i].ConnectionsIDs.size(); j++)
						{
							orderedNeighbours.push_back(node.ConnectionsIDs[j]);
						}

						orderedNodesnums.push_back(orderedNeighbours);

					}
				}
			}
			
			for (u16 i = 0; i < allNodes.size(); i++)
			{
				allNodes[i].PathTo.set_length(allNodes.size());
				for (u16 j = 0; j < allNodes.size(); j++)
				{			
					if (i == j) continue;
					GenShortestPathFromTo(i, j, orderedNodesnums);
				}
			}
		}
	}
	void GenShortestPathFromTo(u16 startnodenum, u16 endnodenum, u16[][] NeighbourNums)
	{
        Path@[] temppaths();
        Node@[] tempnodes();
        tempnodes.push_back(allNodes[startnodenum]);

		f32 ShortestPathLength = 999999.9f;
		f32 CurrentPathLength = 0.0f;

		u16[] closedNodes;
		closedNodes.push_back(startnodenum);

		u16[] currentPath;
		currentPath.push_back(startnodenum);

        u16 LastNode = 255;
      	u16 CurrentNodeNum = startnodenum;
		bool ShortestPathSet = false;

		//print("starting path from "+startnodenum + " to "+ endnodenum);
        while (!ShortestPathSet)
        {
        	f32 NextNodeDist = 0;
        	u16 NextNode = 255;

        	for (u16 i = 0; i < NeighbourNums[CurrentNodeNum].length; i++) 
	        {
	        	u16 n = NeighbourNums[CurrentNodeNum][i]; 
	    		f32 dist = (allNodes[CurrentNodeNum].Position - allNodes[n].Position).getLength();

	    		if ( n == endnodenum && currentPath.size() == 1)
	    		{  		            	
					CurrentPathLength += NextNodeDist;				
					tempnodes.push_back(allNodes[n]);

	            	Path shortestpath = Path(tempnodes, CurrentPathLength);
		        	@allNodes[startnodenum].PathTo[endnodenum] = shortestpath;

				    return;
	    		}	    		
	        	else if (closedNodes.find(n) == -1 && currentPath.find(n) == -1 /*&& (CurrentPathLength+dist <= ShortestPathLength)*/ && n !=startnodenum && n != LastNode)
	        	{  
	    			NextNode = n;
	        		NextNodeDist = dist;
	        		break;
	        	}	
	        }

            if ( NextNode != 255 ) // Advance to neighbour
            {	            	
				LastNode = CurrentNodeNum;
				CurrentNodeNum = NextNode;
				CurrentPathLength += NextNodeDist;
			
				currentPath.push_back(CurrentNodeNum);
				tempnodes.push_back(allNodes[CurrentNodeNum]);

				closedNodes.push_back(CurrentNodeNum);

				if ( CurrentNodeNum == endnodenum ) // Set a temp path
	            {  
					//ShortestPathLength = CurrentPathLength;
	            	Path@ temp = Path(tempnodes, CurrentPathLength);
	            	temppaths.push_back(temp); 
	            }			
            }
            else // go back
            {
		        if (CurrentNodeNum != startnodenum)
		        {
		        	if (LastNode != currentPath[currentPath.size()-1] && closedNodes.find(LastNode) != -1)
		        	closedNodes.removeAt(closedNodes.find(LastNode));

		            currentPath.removeLast();
			    	tempnodes.removeLast();
			    	LastNode = CurrentNodeNum;
			        CurrentNodeNum = currentPath[currentPath.size()-1];       
			    	f32 olddist = (allNodes[CurrentNodeNum].Position - allNodes[LastNode].Position).Length();	            	
			    	CurrentPathLength -= olddist;
		        }		         
		        else // At start Node, with no open nodes, meaning we have checked all possible paths
		        { 
		        	f32 shortest = 999999;
		        	uint shortestIndex = 999;
		        	for (int i = 0; i < temppaths.size(); i++)
		        	{
		        		if (temppaths[i].Length < shortest)
		        		{
		        			shortest = temppaths[i].Length;
		        			shortestIndex = i;
		        		}
		        	}		        	
		        	//print("tempaths.size "+temppaths.size());
			        //print("pushed path from "+allNodes[startnodenum].ID + " to "+ shortestpath.Nodes[shortestpath.Nodes.size()-1].ID );
		        	if (temppaths.size() != 0) // if there are 0 temp paths you are probably setting your nodes up wrong
		        	{
			        	Path shortestpath = temppaths[shortestIndex];
			        	@allNodes[startnodenum].PathTo[endnodenum] = shortestpath;	
			        }

		        	ShortestPathSet = true;	
		            return;
		        }            	
            }
	    }
    }

	bool AnyOpenNodesHere(u16 CurrentNodeNum, u16[][] openNodes)
    {
    	for (uint i = 0; i < allNodes[CurrentNodeNum].ConnectionsIDs.size(); i++)
		{					
			u16 n = allNodes[CurrentNodeNum].ConnectionsIDs[i];
			if (openNodes[CurrentNodeNum].find(n) != -1)
    		{     			
    			return true;
            }
        }
    	return false;
    }

	u16 getClosestWaypointNumToPos(Vec2f pos)
	{		
		f32 closestDist = 999999.9f;
		uint closestIndex = 999;

		for (uint i = 0; i < allNodes.size(); i++)
		{
			Vec2f wpos = allNodes[i].Position;
			f32 dist = (wpos - pos).Length();
			if (dist < closestDist)
			{			
				closestDist = dist;
				closestIndex = i;			
			}
		}
		return closestIndex;
	}

	Path@ FindPathToClosestPlayer(Vec2f startpos, CBlob@ &out Target)
	{
		CBlob@[] blobs;
		getBlobsByTag("player", @blobs );
		f32 best_dist = 99999999;
		Path@ path;

		Node@ startNode = allNodes[this.getClosestWaypointNumToPos(startpos)];

		for (uint i = 0; i < blobs.size(); i++)
		{
			CBlob@ b = blobs[i];				
			if (b !is null && !b.hasTag("dead")  && !b.hasTag("downed"))
			{				
				Vec2f bpos = b.getPosition();
				u16 EndNum = this.getClosestWaypointNumToPos(bpos);
				Path@ test_path = startNode.PathTo[EndNum];

				if (test_path !is null)
				{
					if (test_path.Length < best_dist)
					{				
						best_dist = test_path.Length;
						@path = test_path;
						@Target = b;
					}
				}
			}
		}
		return path;
	}
}

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{	
	MapWaypoints waypoints;
	this.set("MapWaypoints", @waypoints);
}


/*
u16 StartNum;
u16 startnode = 0;
u16 endnode = 0;

void onTick(CRules@ this)
{
	MapWaypoints@ waypoints;
	if (!this.get("MapWaypoints", @waypoints)) return;

		if (getLocalPlayerBlob() is null) return;

		Vec2f mousepos = getControls().getMouseWorldPos();
		startnode = waypoints.getClosestWaypointNumToPos(getLocalPlayerBlob().getPosition());
		endnode = waypoints.getClosestWaypointNumToPos(mousepos);

	//if (getGameTime() % 2 == 0)
	//{
	//	endnode++;
	//	if (endnode >= waypoints.allNodes[startnode].PathTo.size())
	//	{
	//		endnode = 0;
	//		startnode++;
	//		if (startnode >= waypoints.allNodes.size())
	//			startnode = 0;
	//	}
	//}

}

void onRender(CRules@ this)
{
	MapWaypoints@ waypoints;
	if (!this.get("MapWaypoints", @waypoints)) return;

	if (waypoints.allNodes[startnode].PathTo[endnode] !is null)
	waypoints.allNodes[startnode].PathTo[endnode].Render();	
}