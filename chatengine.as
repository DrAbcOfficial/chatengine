#include "CCachePlayer"
#include "CClientCmd"
#include "CKeyWord"
#include "CHandlePackage"
#include "Command"
#include "CommandFunc"
#include "Config"
#include "Hook"
#include "IO"
#include "Logger"
#include "Player"
#include "String"
#include "Utility"
#include "KeywordReplace"
#include "ChatSound"
#include "CVote"
#include "CDFA"
#include "CVars"

bool IsStarted = false;



void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo( "Bruh" );

    @CVar::pRootPath = CCVar("cte_root_path", "scripts/plugins/store/chatengine/", "rootpath", ConCommandFlag::AdminOnly, @CommandFunc::RootCVarCallback);
    
    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @Hook::ClientSay);
	g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @Hook::ClientConnected);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @Hook::ClientDisconnect );

    Logger::GetSayLogSavePath();
    Logger::WriteLine("正在构建敏感词库");
    IO::CensorDataBuilder(Config::General::szRootPath + Config::General::szCensorData);

	IsStarted = false;

	Command::Register( "help", "", "Get all avaliable command", "[Name] [HelpInfo] [DescribeInfo] [AdminLevel]", @CommandFunc::GetHelp );
	Command::Register( "info", "", "Get Plugin Info", "", @CommandFunc::GetInfo );
    Command::Register( "listsound", "", "Get all avaliable sound trigger", "", @CommandFunc::GetSounds );
    Command::Register( "smenu", "", "Show the sound trigger menu", "", function( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd){ ChatSound::pMenu.Open(0, 0, @pPlayer);return true;});
	Command::Register( "setpitch", "", "Set sound trigger pitch", "", @CommandFunc::SetPitch );
    Command::Register( "votekick", "", "Start vote kick someone", "", @CommandFunc::VoteKick);
	Command::Register( "keyword", "", "Get all avaliable keywords", "", @CommandFunc::GetKeyWords );
	Command::Register( "last", "", "Get recent mute log", "", @CommandFunc::GetLogList, ConCommandFlag::AdminOnly );
	Command::Register( "lastb", "", "Get banned player list", "", @CommandFunc::GetBanList, ConCommandFlag::AdminOnly );
	Command::Register( "lastg", "", "Get muted player list", "", @CommandFunc::GetGargList, ConCommandFlag::AdminOnly );
	Command::Register( "dumpinfo", "", "Show players info", "", @CommandFunc::DumpPlayerInfo, ConCommandFlag::AdminOnly );
	Command::Register( "dumptofile", "<string:FileName>", "Dump all info to a file", "Dumped all info to a file", @CommandFunc::DumpInfoToFile, ConCommandFlag::AdminOnly );
	Command::Register( "addban", "[1/0:Add/Remove] [string:SteamID]", "Add or Remove a player from Ban list", "", @CommandFunc::AddBanList, ConCommandFlag::AdminOnly );
	Command::Register( "addgarg", "[1/0:Add/Remove] [string:SteamID]", "Add or Remove a player from Mute list", "", @CommandFunc::AddGargList, ConCommandFlag::AdminOnly );
    Command::Register( "addmute", "[1/0:Add/Remove] [string:SteamID]", "Fooking stop spam fooking sound bitch", "", @CommandFunc::AddMuteList, ConCommandFlag::AdminOnly );
	Command::Register( "kick", "[string:SteamID] <string:Reason>", "Kick a player", "Kicked", @CommandFunc::KickPlayer, ConCommandFlag::AdminOnly );
    Command::Register( "banmanually", "[string:SteamID] <string:IP> <string:Name> <string:Reason>", "Add a player to Ban list manually", "", @CommandFunc::AddBanListMnually, ConCommandFlag::AdminOnly );
    Command::Register( "dumpcsdstic", "", "Get all chatsound static info", "", @ChatSound::Out, ConCommandFlag::AdminOnly );

	KeywordReplace::Register( "time", @KeywordReplaceFunc::Time );
	KeywordReplace::Register( "pos", @KeywordReplaceFunc::Pos );
	KeywordReplace::Register( "weapon", @KeywordReplaceFunc::Weapon );
	KeywordReplace::Register( "hp", @KeywordReplaceFunc::HP );
	KeywordReplace::Register( "ap", @KeywordReplaceFunc::AP );
	KeywordReplace::Register( "texture", @KeywordReplaceFunc::Texture );
	KeywordReplace::Register( "death", @KeywordReplaceFunc::Death );
	KeywordReplace::Register( "frags", @KeywordReplaceFunc::Frags );

	ChatSound::ReadSounds();
    ChatSound::PluginInit();
    Logger::Say(Config::Launguage::szGeneralStarting);
}

void MapInit()
{
	if(!IsStarted)
		IsStarted = true;

	//换图更新列表
	if(!IO::BanListReader())
		Logger::WriteLine(Utility::SnipLaunguage(Config::Launguage::szFailLoadPlugin, Config::General::szRootPath + Config::General::szFilePath));
	else
		Logger::WriteLine(Utility::SnipLaunguage(Config::Launguage::szLoadedPlugin, string(Player::aryBanList.length())));
	if(!IO::BanListReader(Player::aryGargList, Config::General::szRootPath + Config::General::szMuteFilePath))
		Logger::WriteLine(Utility::SnipLaunguage(Config::Launguage::szMuteFailLoadPlugin, Config::General::szRootPath + Config::General::szMuteFilePath));
	else
		Logger::WriteLine(Utility::SnipLaunguage(Config::Launguage::szMuteLoadedPlugin, string(Player::aryGargList.length())));

	ChatSound::Precache();
    ChatSound::MapInit();

    ChatSound::MapOutData();
    ChatSound::CleanData();

	//清空Detect
    for(uint i = 0; i < Player::aryCachePlayerList.length(); i++)
    {
        Player::aryCachePlayerList[i].Detect = 0;
    }
}
