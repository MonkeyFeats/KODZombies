#define CLIENT_ONLY
#include "HoverMessage.as"

const int fade_time = 30;

class CoinMessage
{
	string amount;
	s16 time;
	Vec2f velocity;
	Vec2f velocity_offset;
	SColor col;

	CoinMessage() {}  //dont use this

	CoinMessage(string coinage, Vec2f startpos)
	{
		amount = coinage;
		time = fade_time;
		velocity_offset = startpos;
		velocity = getRandomVelocity(90, 0.04f + 0.01f * XORRandom(10), 60.0f);
		col = color_white;
	}
};

class CoinFeed
{
	CoinMessage[] coinMessages;

	void Update()
	{
		while (coinMessages.length > 10)
		{
			coinMessages.erase(0);
		}

		for (uint message_step = 0; message_step < coinMessages.length; ++message_step)
		{
			CoinMessage@ message = coinMessages[message_step];
			message.time--;
			message.velocity_offset += message.velocity*message.time;
			message.col.setAlpha((message.time*(255/fade_time)));

			if (message.time == 0)
				coinMessages.erase(message_step--);
		}
	}

	void Render()
	{
		const uint count = Maths::Min(10, coinMessages.length);
		GUI::SetFont("menu");

		for (uint message_step = 0; message_step < count; ++message_step)
		{
			CoinMessage@ message = coinMessages[message_step];
			GUI::DrawText(message.amount, message.velocity_offset, message.col);
		}
	}

};

