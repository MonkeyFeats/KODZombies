#define CLIENT_ONLY
#include "HoverMessage.as"

const int fade_inout_time = 45;

class InteractionMessage
{
	CBlob@ OwnerBlob;
	CBitStream requirements;
	u16 CommandID;
	string Text;
	string ActivationText;
	SColor Color;
	Vec2f Position;
	//float EnableRadius;	
	//CBitStream params;
	int fadeAmount;

	bool isHovered;

	InteractionMessage(CBlob@ _b, string _text, string _actText, Vec2f _pos, SColor _col, /*float _enableRadius,*/ u16 _cmdID /*, CBitStream _params*/)
	{		
		@OwnerBlob = _b;
		Text = _text;
		ActivationText = _actText;
		Position = _pos;
		Color = _col;
		//EnableRadius = _enableRadius;
		CommandID = _cmdID;	
		//params = _params;

		fadeAmount = 0;
	}	

	void Render()
	{
		GUI::DrawTextCentered(ActivationText+" "+Text, getDriver().getScreenPosFromWorldPos(Position), Color);
		GUI::DrawTextCentered("For "+"750 Coins", getDriver().getScreenPosFromWorldPos(Position+Vec2f(0,4)), Color);
	}
	
	bool opEquals(InteractionMessage@ other)
	{
		return this.OwnerBlob is other.OwnerBlob;
	}
};

class InteractionMessages
{
	InteractionMessage[] messages;

	void Update(Vec2f blobPos)
	{
		for (uint message_step = 0; message_step < messages.size(); ++message_step)
		{			
			InteractionMessage@ message = messages[message_step];

			f32 dist = (message.OwnerBlob.getPosition() - blobPos).Length();

			if (dist > 8.0f)
			message.isHovered = false;

			if (message.isHovered && message.fadeAmount < 255)
			{
				message.fadeAmount += (255/fade_inout_time);
				if (message.fadeAmount > 255) message.fadeAmount = 255;
				message.Color.setAlpha(message.fadeAmount);
			}
			else if (message.fadeAmount > 0)
			{
				message.fadeAmount -= (255/fade_inout_time);
				if (message.fadeAmount < 0) message.fadeAmount = 0;
				message.Color.setAlpha(message.fadeAmount);
			}
			else
			{
				messages.erase(message_step);
			}
		}
	}

	void AddMessage(InteractionMessage@ message)
	{
		messages.push_back(message);	
	}

	void Render()
	{
		GUI::SetFont("menu");

		for (uint message_step = 0; message_step < messages.size(); ++message_step)
		{
			InteractionMessage@ message = messages[message_step];
			message.Render();
		}
	}
};

