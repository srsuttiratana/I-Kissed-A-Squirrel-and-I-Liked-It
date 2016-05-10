#include "stdafx.h"
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include <iostream>

using namespace std;

void playAudio(string file_name)
{
	sf::Music music;
	if (!music.openFromFile(file_name))
	{
		cout << "Couldn't open file.\n";
	}
	else
	{
		music.play();
		cout << "Successfully playing song." << endl;
		while (music.getStatus() == sf::SoundSource::Playing)
		{

		}
		cout << "Song is over." << endl;
	}
}

int main()
{
	sf::RenderWindow window(sf::VideoMode(200, 200), "SFML works!");
	sf::CircleShape shape(100.f);
	shape.setFillColor(sf::Color::Green);

	playAudio("Start.wav");
	//change the audio file name here
	//place the sound files in the folder where this .cpp file is

	while (window.isOpen())
	{
		sf::Event event;
		while (window.pollEvent(event))
		{
			if (event.type == sf::Event::Closed)
				window.close();
		}

		window.clear();
		window.draw(shape);
		window.display();
	}



	return 0;
}

