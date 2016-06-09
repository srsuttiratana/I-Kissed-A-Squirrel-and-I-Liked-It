----------------------------------------------------------------------------------------------------
--
-- All or portions of this file Copyright (c) Amazon.com, Inc. or its affiliates or
-- its licensors.
--
-- For complete copyright and license terms please see the LICENSE at the root of this
-- distribution (the "License"). All use of this software is governed by the License,
-- or, if provided, by the license below or the license accompanying this file. Do not
-- remove or modify any license notices. This file is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--
-- Original file Copyright Crytek GMBH or its affiliates, used under license.
--
----------------------------------------------------------------------------------------------------
Script.ReloadScript( "SCRIPTS/Entities/AI/Characters/Human_x.lua")
Script.ReloadScript( "SCRIPTS/Entities/actor/BasicActor.lua")
Script.ReloadScript( "SCRIPTS/Entities/AI/Shared/BasicAI.lua")

Medic_x = {
  Properties = {
    bAdditionalBool = false,
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
	
	xml_def_path = "SCRIPTS/stalker_conversations_def.xml",
	xml_data_path = "SCRIPTS/XMLData",
	
	dictionary_def_path = "SCRIPTS/Dictionary_Def.xml",
	dictionary_data_good_path = "SCRIPTS/XMLData/Dictionary_Data_Good.xml", -- Dictionary of learned "good" words. Modified at runtime by AI.
	dictionary_data_bad_path = "SCRIPTS/XMLData/Dictionary_Data_Bad.xml", -- Dictionary of learned "bad" words. Modified at runtime by AI.
}

function Medic_x:OnInit()
	self:Activate(1);
	self.load_dialogue_table();
end

-----------------------------------------------------------------------------------------------------------------------
------ Load Dialogue Tables 
-----------------------------------------------------------------------------------------------------------------------
-- Load table for all dialogue. Used by 'OnInit()'
function Medic_x:load_dialogue_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker__conversations_data_IDs.xml" );
end

--[[
-- Load table for the 'Intro' conversations
function Medic_x:load_intro_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_intro_data.xml" );
end

-- Load table for the 'Gets Tackled by Police Officer' conversations
function Medic_x:load_police_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_police_data.xml" );
end

-- Load table for the 'First meeting' conversations
function Medic_x:load_first_meeting_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_first_meeting_data.xml" );
end

-- Load table for the 'First date' conversations
function Medic_x:load_first_date_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_first_date_data.xml" );
end

-- Load table for the 'Second date' conversations
function Medic_x:load_second_date_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_second_date_data.xml" );
end

-- Load table for the 'Proposal' conversations
function Medic_x:load_first_date_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_proposal_data.xml" );
end

-- Load table for the 'Wedding' conversations
function Medic_x:load_first_date_table() 
	self.dialogue_table = {};
	self.dialogue_table = CryAction.LoadXML( self.xml_def_path, self.xml_data_path .. "/stalker_wedding_data.xml" );
end
--]]

-----------------------------------------------------------------------------------------------------------------------
------ Load/Modify Dictionaries
-----------------------------------------------------------------------------------------------------------------------
-- Load "Good" Dictionary. Used by 'parse_sentence(...)'
function Medic_x:load_dictionary_good()
	self.dictionary_good = {};
	self.dictionary_good = CryAction.LoadXML( self.dictionary_def_path, self.dictionary_data_good_path);
end

-- Load "Bad" Dictionary. Used by 'parse_sentence(...)'
function Medic_x:load_dictionary_bad()
	self.dictionary_bad = {};
	self.dictionary_bad = CryAction.LoadXML( self.dictionary_def_path, self.dictionary_data_bad_path);
end

-- Add word to Dictionary (Word has not point value if it's in both "Good" and "Bad"?). Used by 'score_word(...)'
function Medic_x:add_word(word, dictionaryType)
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
function Medic_x:score_word(word, score)
	if(score > 0) then
		self.add_word(word, "Good");
	else
		self.add_word(word, "Bad");
	end
end

-- Get individual word scores. Used by 'parse_sentence(...)'
function Medic_x:get_word_score(word)
	goodWordCount = 0;
	badWordCount = 0;
	
	-- Search through "Good" dictionary and get count of "word"
	self.load_dictionary_good();
	for i, wg in ipairs(dictionary_good) do
		if(wg == "word") then	
			goodWordCount = goodWordCount + 1;
		end
	end
	
	-- Search through "Bad" dictionary and get count of "word"
	self.load_dictionary_bad();
	for i, wb in ipairs(dictionary_bad) do
		if(wb == "word") then	
			badWordCount = badWordCount + 1;
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
function Medic_x:parse_sentence(id, option)
	sentence = self.dialogue_table[id];
	points = 0;
	
	for i, word in ipairs(sentence) do
		word_score = self.get_word_score(word);
		--don't need to add word to dictionaries
		--self.add_word(word, word_score);
		points = points + word_score;
	end
	
	if(option == "A") then
		points_A = points;
	elseif(option == "B") then
		points_B = points;
	elseif(option == "C") then
		points_C = points;
	end
	
end

-- Given all options, parse them into dictionaries and calculate score
function Medic_x:parse_all_options(a, b, c)
	if not (a == nil or a == "") then
		parse_sentence(a, "A");
	end
	if not (b == nil or b == "") then
		parse_sentence(b, "B");
	end
	if not (c == nil or c == "") then
		parse_sentence(c, "C");
	end
	
end

-- Output of flow node. Goes to selected option. 
function Medic_x:choose_option()
	total = points_A + points_B + points_C;
	A_ratio = points_A/total;
	B_ratio = points_B/total;
	C_ratio = points_C/total;

	---- Compare points for each option with some randomness
	-- No option C
	if(points_C <= 0) then
		if(points_A > points_B and math.random(0,100) < A_ratio*100) then
			BroadcastEvent(self, "A");
		else 
			BroadcastEvent(self, "B");
		end
	-- All options available
	else
		-- A > all other options
		if(points_A > points_B and points_A > points_C and math.random(0,100) < A_ratio*100) then
			BroadcastEvent(self, "A");
		-- B > all other options
		elseif(points_B > points_A and points_B > points_C and math.random(0,100) < B_ratio*100) then
			BroadcastEvent(self, "B");
		-- C > all other options
		elseif(points_C > points_A and points_C > points_B and math.random(0,100) < C_ratio*100) then
			BroadcastEvent(self, "C");
		-- No single option better than all others. Choose semi-randomly while favoring the highest scored options
		else
			if(math.random(0,100) < A_ratio*100) then
				BroadcastEvent(self, "A");
			elseif(math.random(0,100) < B_ratio*100) then
				BroadcastEvent(self, "B");
			elseif(math.random(0,100) < C_ratio*100) then
				BroadcastEvent(self, "C");
			else
				BroadcastEvent(self, "A");
			end
		end
	end
end

--If get negative response, put all words in the dialogue option in bad dictionary. If get neutral response, don't put any words
--in the dictionaries. If get positive response, put all words in the dialogue option in good dictionary.
function Medic_x:add_to_dictionary(id, typeOfDictionary)
	sentence = self.dialogue_table[id];
	
	if (typeOfDictionary == "Good") then
		for i, word in ipairs(sentence) do
			self.add_word(word, "Good");
		end
	elseif (typeOfDictionary == "Bad") then	
		for i, word in ipairs(sentence) do
			self.add_word(word, "Bad");
		end
	end	
end


function Medic_x:OnEnemySeen()
  AIBase.OnEnemySeen(self);
  
  local attentionTarget = AI.GetAttentionTargetEntity(self.id);
  
  if (attentionTarget.Properties.esFaction == "Players" and attentionTarget.actor:GetHealth() < 500) then
    AI.Signal(SIGNALFILTER_SENDER, 1, "OnInjuredPlayerSeen", self.id);
  end
end

function Medic_x:HealPlayer()
  local attentionTarget = AI.GetAttentionTargetEntity(self.id);
  attentionTarget.actor:SetHealth(1000);  
end

function Medic_x:Pick2Options()
	--AI picks based on (option A points/ total points)% or (option B points/ total points)
	--use math.random(0, total points)
	--if (math.random < option A points)
	--	executeOptionA
	--else
	-- 	executeOptionB
	
	--testing purposes
	--PickOptionA();
	local randomSelection = math.random(0, 100);
	if (randomSelection < 50) then
		--BroadcastEvent(self, "A");
		self:ActivateOutput( "A", true );
	else
		--BroadcastEvent(self, "B");
		self:ActivateOutput( "B", true );
	end
end

function Medic_x:Pick3Options()
	--AI picks based on (option A points/ total points)% or (option B points/ total points)
	--use math.random(0, total points)
	--if (math.random < option A points)
	--	executeOptionA
	--else
	-- 	executeOptionB
	
	--testing purposes
	local randomSelection = math.random(0, 100);
	if (randomSelection < 33) then
		BroadcastEvent(self, "A");
	elseif (randomSelection < 66) then
		BroadcastEvent(self, "B");
	else
		BroadcastEvent(self, "C");
	end
	
end

mergef(Medic_x,Human_x,1)

CreateActor(Medic_x)
Medic=CreateAI(Medic_x)

Script.ReloadScript( "SCRIPTS/AI/Assignments.lua")
InjectAssignmentFunctionality(Medic)
AddDefendAreaAssignment(Medic)
AddHoldPositionAssignment(Medic)
AddCombatMoveAssignment(Medic)
AddPsychoCombatAllowedAssignment(Medic)

Medic:Expose()

function Medic:On_Event(sender, params)
  --self.event_list[#self.event_list+1] = { t = self.time_elapsed, event = params };
  
  --if params == "Jump" then
    
  --end
  
  --System.Log("Event: " .. params);
  
end

Medic.FlowEvents = {
  Inputs = {
    Event = { Medic.On_Event, "string" },
	ParseSentence = { Medic_x.parse_all_options, "int", "int", "int" },
  },
  Outputs = { A = "any",
			B = "any",
			C = "any"
	},
}