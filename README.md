# I Kissed a Squirrel and I Liked It
<b>NOTE: Please upload all assets to the shared Google Drive folder! We can upload our scripts here for version control purposes. </b><br><br>
<b>Pre-Requisites</b><br>
1. Download the Legacy Code at http://aws.amazon.com/lumberyard/downloads/<br>
2. Download the Beach City assets at http://aws.amazon.com/lumberyard/downloads/<br>
3. Extract the files from the zip file for the Legacy Code. Cut the folder called 'GameSDK' and place it in 'C:\Amazon\Lumberyard\1.1.0.0\dev'.<br>
4. Extract the files from the zip file. There should be a folder called 'dev' that all files are placed in. <br>
5. Within Beach City's 'dev' folder, there should be 4 folders. Place whatever is in 'Code', 'Cache' and 'Bin64' in their respective folders within C:\Amazon\Lumberyard\1.1.0.0\dev.<br>
6. There should be one more folder called 'Beach City'. Place this folder under C:\Amazon\Lumberyard\1.1.0.0\dev. <br>
7. Download the Woodland Asset Collection here: http://aws.amazon.com/lumberyard/downloads/<br>
8. Extract the files from the zip file.<br>
9. From the zip file, cut the folders within the 'Objects' folder and paste them into       'C:\Amazon\Lumberyard\1.1.0.0\dev\GameSDK\Objects'<br>
10. Place the folders 'Diner' and 'Dense Forest World' (which are in the Google Drive) in the path C:\Amazon\Lumberyard\1.1.0.0\dev\GameSDK\Levels.<br> 
11. Download the 'Pachirisu' folder in the 3D Models folder from Google Drive. Place it in  'C:\Amazon\Lumberyard\1.1.0.0\dev\GameSDK\Objects\characters' <br>
12. Open Lumberyard Project Configurator and configure the 'GameSDK' project.<br>

EDIT: If you don't want all the Beach City assets, you only need the following Objects in the Beach City folder: <br>
- BeachCity\Architecture\Diner<br>
- Everything under BeachCity\Props that begins with "Diner_"<br>
- BeachCity\Props\JukeBox<br>

I think that's all the assets you need from Beach City. But if I'm missing one, let me know!<br>

<b>Keeping Track of the Player's Score Across Levels</b><br>
I created a file called "PlayerScore.xml". It should be in the GameSDK folder, because otherwise Lumberyard can't find it. It seems that there are problems with game tokens being transferred across different levels. So one of the solutions was to store the score in an xml file. Basically, I plan on having a game token in each level keep track of how many points the player has accumulated through the conversation. After the conversation is over, PlayerScore.xml will be opened and I will extract the score from it. I will then add the score from PlayerScore.xml to the game token. Then I will set the value in PlayerScore.xml to the game token's modified value, and save the xml document. It's weird because I can see that the xml file doesn't appear to have changed after the level. However, after I go through the conversation again, the score stored in the xml file has been saved from the last conversation (I can see through the debug log). <br>

<b>Compiling a Visual Studio Solution</b><br>
1. Follow the instructions here: http://docs.aws.amazon.com/lumberyard/latest/userguide/game-build-game-code.html <br>
2. Change the user_settings.options file in 'C:\Amazon\Lumberyard\1.1.0.0\dev\_WAF_' to the user_settings.options here on GitHub.<br>
3. Type 'lmbr_waf configure' from the command prompt within the 'C:\Amazon\Lumberyard\1.1.0.0\dev' folder.<br>
