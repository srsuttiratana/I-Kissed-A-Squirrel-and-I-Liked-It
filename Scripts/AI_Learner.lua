AI_Learner = 
{
	Properties = {
	
	},
	
	Editor = {
		Icon = "bug.bmp", 
	},
	
	-- Points that are gained or lost through selecting dialogue options from UI during dates
	score = {
		points_A = 0,
		points_B = 0,
		points_C = 0,
	},
	
	dialogue_table = {},
	dictionary_good = {},
	dictionary_bad = {},
	
	xml_def_path = "stalker_conversations_def.xml",
	xml_data_path = "XMLData",
	
	dictionary_def_path = "Dictionary_Def.xml",
	dictionary_data_good_path = "XMLData/Dictionary_Data_Good.xml", -- Dictionary of learned "good" words. Modified at runtime by AI.
	dictionary_data_bad_path = "XMLData/Dictionary_Data_Bad.xml", -- Dictionary of learned "bad" words. Modified at runtime by AI.
}

function AI_Learner:OnInit()
	self:Activate(1);
	self.load_dialogue_table();
end

-----------------------------------------------------------------------------------------------------------------------
------ Load Dialogue Tables 
-----------------------------------------------------------------------------------------------------------------------
-- Load table for all dialogue. Used by 'OnInit()'
function AI_Learner:load_dialogue_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker__conversations_data_IDs.xml" );
end

--[[
-- Load table for the 'Intro' conversations
function AI_Learner:load_intro_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_intro_data.xml" );
end

-- Load table for the 'Gets Tackled by Police Officer' conversations
function AI_Learner:load_police_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_police_data.xml" );
end

-- Load table for the 'First meeting' conversations
function AI_Learner:load_first_meeting_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_first_meeting_data.xml" );
end

-- Load table for the 'First date' conversations
function AI_Learner:load_first_date_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_first_date_data.xml" );
end

-- Load table for the 'Second date' conversations
function AI_Learner:load_second_date_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_second_date_data.xml" );
end

-- Load table for the 'Proposal' conversations
function AI_Learner:load_first_date_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_proposal_data.xml" );
end

-- Load table for the 'Wedding' conversations
function AI_Learner:load_first_date_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_wedding_data.xml" );
end
--]]

-----------------------------------------------------------------------------------------------------------------------
------ Load/Modify Dictionaries
-----------------------------------------------------------------------------------------------------------------------
-- Load "Good" Dictionary. Used by 'parse_sentence(...)'
function AI_Learner:load_dictionary_good()
	self.dictionary_good = {};
	self.dictionary_good = CryAction.LoadXML( self.dictionary_def_path, self.dictionary_data_good_path);
end

-- Load "Bad" Dictionary. Used by 'parse_sentence(...)'
function AI_Learner:load_dictionary_bad()
	self.dictionary_bad = {};
	self.dictionary_bad = CryAction.LoadXML( self.dictionary_def_path, self.dictionary_data_bad_path);
end

-- Add word to Dictionary (Word has not point value if it's in both "Good" and "Bad"?). Used by 'score_word(...)'
function AI_Learner:add_word(word, dictionaryType)
	if(dictionaryType == "Good") then
		table.insert(dictionary_good, word); -- Inserts word at end of dictionary
		CryAction.SaveXML( self.dictionary_def_path, self.ictionary_data_good_path, self.dictionary_good );
	elseif(dictionaryType == "Bad") then
		table.insert(dictionary_bad, word);
		CryAction.SaveXML( self.dictionary_def_path, self.dictionary_data_bad_path, self.dictionary_bad );
	end
end

-----------------------------------------------------------------------------------------------------------------------
------ Scoring/Calculations
-----------------------------------------------------------------------------------------------------------------------
-- Get score(approval/disapproval) of word and add to appropriate dictionary. Used by 'parse_sentence(...)'
function AI_Learner:score_word(word, score)
	if(score > 0) then
		self.add_word(word, "Good");
	elseif then
		self.add_word(word, "Bad");
	end
end

-- Get individual word scores. Used by 'parse_sentence(...)'
function AI_Learner:get_word_score(word)
	goodWordCount = 0;
	badWordCount = 0;
	
	-- Search through "Good" dictionary and get count of "word"
	self.load_dictionary_good();
	for(i, wg in ipairs(dictionary_good)) do
		if(wg == "word") then	
			goodWordCount += 1;
		end
	end
	
	-- Search through "Bad" dictionary and get count of "word"
	self.load_dictionary_bad();
	for(i, wb in ipairs(dictionary_bad)) do
		if(wb == "word") then	
			badWordCount += 1;
		end
	end
	
	-- Calculate score
	if(goodWordCount > badWordCount) then
		return 10;
	elseif(badWordCount > goodWordCount) then
		return -10;
	else
		return 0;
	end
		
end

-- Parse dialogue word-by-word from "id" (string). Select from dialogue ID (e.g "S1")
function AI_Learner:parse_sentence(id, option)
	sentence = self.dialogue_table[id];
	points = 0;
	
	for(i, word in ipairs(sentence)) do
		word_score = self.get_word_score(word);
		self.add_word(word, word_score);
		points += word_score;
	end
	
	if(option == "A") then
		points_A = points;
	elseif(option == "B") then
		points_B = points;
	elseif(option == "C") then
		points_C = points
	end
	
end

-- Output of flow node. Goes to selected option. 
function AI_Learner:choose_option()
	total = points_A + points_B + points_C;
	A_ratio = points_A/total;
	B_ratio = points_B/total;
	C_ratio = points_C/total;

	---- Compare points for each option with some randomness
	-- No option C
	if(points_C <= 0) then
		if(points_A > points_B && math.random(0,100) < A_ratio*100) then
			return "A";
		else 
			return "B";
		end
	-- All options available
	else
		-- A > all other options
		if(points_A > points_B && points_A > points_C && math.random(0,100) < A_ratio*100) then
			return "A";
		-- B > all other options
		elseif(points_B > points_A && points_B > points_C && math.random(0,100) < B_ratio*100) then
			return "B";
		-- C > all other options
		elseif(points_C > points_A && points_C > points_B && math.random(0,100) < C_ratio*100) then
			return "C";
		-- No single option better than all others. Choose semi-randomly while favoring the highest scored options
		else
			if(math.random(0,100) < A_ratio*100) then
				return "A";
			elseif(math.random(0,100) < B_ratio*100) then
				return "B";
			elseif(math.random(0,100) < C_ratio*100) then
				return "C";
			else
				return "A";
			end
		end		
end

-----------------------------------------------------------------------------------------------------------------------
------ Flow Events
-----------------------------------------------------------------------------------------------------------------------
AI_Learner.FlowEvents = {
  Inputs = {
	ParseSentence = { AI_Learner.parse_sentence, "int" },
  },
  Outputs = {
	ChooseOption = { AI_Learner.choose_option, "string" }, -- Output to chosen dialogue option
  },
}









