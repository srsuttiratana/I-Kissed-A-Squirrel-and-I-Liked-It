#include "StdAfx.h"
#include "FlowBaseNode.h"

#	if defined(_DEBUG)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/sfml-audio-s-d.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/sfml-system-s-d.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/openal32.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/flac.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/vorbisenc.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/vorbisfile.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/vorbis.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/ogg.lib)
	//LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/ogg.lib)
#else
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/sfml-audio-s-d.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/sfml-system-s-d.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/openal32.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/flac.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/vorbisenc.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/vorbisfile.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/vorbis.lib)
	LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/ogg.lib)
	//LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/ogg.lib)
	//LINK_THIRD_PARTY_LIBRARY(SDKs/SFML-2.3.2/lib/libtommath.lib)
#	endif

void playAudio(string file_name);
 
class CFlowNode_PlayAudio : public CFlowBaseNode<eNCT_Instanced>
{
public:
  CFlowNode_PlayAudio(SActivationInfo* pActInfo)
  {
  };
 
  virtual IFlowNodePtr Clone(SActivationInfo *pActInfo)
  {
    return new CFlowNode_PlayAudio(pActInfo);
  };
 
  virtual void GetMemoryUsage(ICrySizer* s) const
  {
     s->Add(*this);
  }
 
  virtual void GetConfiguration(SFlowNodeConfig& config)
  {
    static const SInputPortConfig in_config[] = {
		//InputPortConfig<InputPortConfig_AnyType>("StartPlaying", _HELP("Play audio.")),
		InputPortConfig_Void( "StartPlaying",_HELP("Play audio.") ),
		InputPortConfig<string>("Audio_File", _HELP("Audio file path.")),
      {0}
    };
    static const SOutputPortConfig out_config[] = {
		OutputPortConfig<int>("Result", _HELP("Outputs -1 if song couldn't play.")),
		OutputPortConfig_Void("False", _HELP("Triggered if if song couldn't play.")),
		OutputPortConfig_Void("True",  _HELP("Triggered if if song could play.")),
      {0}
    };
    config.sDescription = _HELP( "Plays audio using the SFML library." );
    config.pInputPorts = in_config;
    config.pOutputPorts = out_config;
    config.SetCategory(EFLN_APPROVED);
  }
 
  virtual void ProcessEvent(EFlowEvent event, SActivationInfo* pActInfo)
  {
     switch (event)
     {
		 //playAudio(Audio_File.value);
		 const string& audio_file = GetPortString(pActInfo, 1);
		 const int result = playAudio(audio_file);
		 ActivateOutput( pActInfo, 0, result);
     };
  }
};

bool playAudio(string file_name)
{
	sf::Music music;
	if (!music.openFromFile(file_name))
	{
		//cout << "Couldn't open file.\n";
		return false;
	}
	else
	{
		music.play();
		//cout << "Successfully playing song." << endl;
		while (music.getStatus() == sf::SoundSource::Playing)
		{

		}
		//cout << "Song is over." << endl;
		return true;
	}
}
 
REGISTER_FLOW_NODE("FlowNodeGroup:PlayAudio", CFlowNode_PlayAudio);