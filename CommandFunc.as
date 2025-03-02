namespace CommandFunc
{
    void RootCVarCallback(CCVar@ cvar, const string& in szOldValue, float flOldValue)
    {
        Config::General::szRootPath = cvar.GetString();
    }
    bool GetHelp( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        Logger::Console(pPlayer, Config::Launguage::szCommandHelp);
        for(uint i = 0; i < Command::aryCmdList.length(); i++)
        {
            if(!Command::aryCmdList[i].IsEmpty())
            {
                CClinetCmd@ eCme = cast<CClinetCmd@>(Command::aryCmdList[i].Get());
                if(g_PlayerFuncs.AdminLevel(pPlayer) < int(eCme.AdminLevel))
                    continue;

                Logger::Console(pPlayer, "| " + String::PadSpace(24, eCme.Name) + " | " + eCme.HelpInfo + " | " + eCme.DescribeInfo + " | " + Utility::GetAdminLevelString(eCme.AdminLevel));
            }
        }
        return true;
    }

    bool VoteKick( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    { 
        CCachePlayer@ pTarget = Player::GetCache(pArgs[1]);
        if(@pTarget is null){
            Logger::Console(@pPlayer, pArgs[1] + "指向的玩家不存在");
            return false;
        }
        CVote@ pVote = CreatVote("kick " + pTarget.Name, string(pPlayer.pev.netname) + " Started a Vote:\nWould you like to KICK: " + pTarget.Name + "?\n", @pPlayer);
        pVote.dicArgument["target"] = pTarget.SteamID;
        pVote.setCallBack(function(CVote@ pSelf, bool bResult, int iVoters){
            Player::Kick(string(pSelf.dicArgument["target"]), "你被: " + pSelf.pOwner.pev.netname + "投票以" + iVoters + "票踢出了服务器.");
        });
        pVote.Start();
        return true;
    }

    bool GetInfo( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        Logger::Console(pPlayer, "Plugin:");
        Logger::Console(pPlayer, "  Version-" + Config::General::szVersion);
        Logger::Console(pPlayer, "  ModuleName-" + get_g_Module().GetModuleName());
        Logger::Console(pPlayer, "  Author-" + get_g_Module().get_ScriptInfo().GetAuthor());
        Logger::Console(pPlayer, "  ContactInfo-" + get_g_Module().get_ScriptInfo().GetContactInfo());
        array<string> aryNamespace = {};
        for(uint i = 0; i < Reflection::g_Reflection.Module.GetGlobalFunctionCount();i++)
        {
            string szTemp = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex(i).GetNamespace();
            if(szTemp == "")
                szTemp = "Global";
            if(aryNamespace.find(szTemp) < 0)
                aryNamespace.insertLast(szTemp);
        }
        Logger::Console(pPlayer, "  Avaliable Plugin Module:");
        for(uint i = 0; i < aryNamespace.length();i++)
        {
            Logger::Console(pPlayer, "    <" + aryNamespace[i] + ">");
        }
        Logger::Console(pPlayer, "Game:");
        Logger::Console(pPlayer, "  Name-" + g_Game.GetGameName());
        Logger::Console(pPlayer, "  Version-" + g_Game.GetGameVersionString());
        Logger::Console(pPlayer, "  Directory-" + g_EngineFuncs.GetGameDir());
        Logger::Console(pPlayer, "  Dedicated-" + g_EngineFuncs.IsDedicatedServer());
        Logger::Console(pPlayer, "AngelScript:");
        Logger::Console(pPlayer, "  Description-" + g_Angelscript.GetAngelscriptDescription() );
        Logger::Console(pPlayer, "  Version-" + g_Angelscript.GetAngelscriptVersion());
        return true;
    }

    bool AddBanList( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        if(pArgs[1] == "" || pArgs[2] == "")
            return false;
        
        if(pArgs[1] == "1")
        {
            CCachePlayer@ pCache = Player::GetCache(pArgs[2]);
            if(@pCache is null)
            {
                Logger::Console(pPlayer, "Can not find Player with SteamID: " + pArgs[2]);
                return false;
            }

            Logger::Console(pPlayer, "Added Banned Player: " + pCache.Name + " [" + pCache.SteamID + "]");
            Player::NewBan(pCache);
            return true;
        }
        else if(pArgs[1] == "0")
        {
            CCachePlayer@ pCache = Player::GetBanCache(pArgs[2]);
            if(@pCache is null)
            {
                Logger::Console(pPlayer, "Can not find Player with SteamID in banned players: " + pArgs[2]);
                return false;
            }

            Logger::Console(pPlayer, "Removed Banned Player: " + pCache.Name + " [" + pCache.SteamID + "]");
            return Player::RemoveBan(pCache);
        }
        else
            return false;
    }
	
	bool KickPlayer ( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        if(pArgs[1] == "")
            return false;
        
        CCachePlayer@ pCache = Player::GetCache(pArgs[1]);
        if(@pCache is null)
        {
            Logger::Console(pPlayer, "Can not find Player with SteamID: " + pArgs[1]);
            return false;
        }
		
		string szReason = (pArgs[2] == "") ? "You have been kicked." : pArgs[2];
        Logger::Console(pPlayer, "Kicked Player: " + pCache.Name + " [" + pCache.SteamID + "] with reason: " + szReason + "");
        Player::Kick(pCache.SteamID, szReason);
        return true;
    }

    bool AddGargList( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        if(pArgs[1] == "" || pArgs[2] == "")
            return false;
        
        if(pArgs[1] == "1")
        {
            CCachePlayer@ pCache = Player::GetCache(pArgs[2]);
            if(@pCache is null)
            {
                Logger::Console(pPlayer, "Can not find Player with SteamID: " + pArgs[2]);
                return false;
            }
            Logger::Console(pPlayer, "Added Garged Player: " + pCache.Name + " [" + pCache.SteamID + "]");   
            Player::NewGarg(pCache);
            return true;
        }
        else if(pArgs[1] == "0")
        {
            CCachePlayer@ pCache = Player::GetGargCache(pArgs[2]);
            if(@pCache is null)
            {
                Logger::Console(pPlayer, "Can not find Player with SteamID in garged players: " + pArgs[2]);
                return false;
            }

            Logger::Console(pPlayer, "Removed Garged Player: " + pCache.Name + " [" + pCache.SteamID + "]");
            Player::RemoveGarg(pCache);
            return true;
        }
        else
            return false;
    }

    bool AddMuteList( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        if(pArgs[1] == "" || pArgs[2] == "")
            return false;
        
        if(pArgs[1] == "1")
        {
           CCachePlayer@ pCache = Player::GetCache(pArgs[2]);
            if(@pCache is null)
            {
                Logger::Console(pPlayer, "Can not find Player with SteamID in muted players: " + pArgs[2]);
                return false;
            }
            if(ChatSound::aryMuter.find(pCache) < 0)
                ChatSound::aryMuter.insertLast(pCache);
            Logger::Console(pPlayer, "Added muted Player: " + pCache.Name + " [" + pCache.SteamID + "]");   
            return true;
        }
        else if(pArgs[1] == "0")
        {
            CCachePlayer@ pCache = Player::GetCache(pArgs[2]);
            if(@pCache is null)
            {
                Logger::Console(pPlayer, "Can not find Player with SteamID in muted players: " + pArgs[2]);
                return false;
            }
            uint index = ChatSound::aryMuter.find(pCache);
            if(index >= 0)
                ChatSound::aryMuter.removeAt(index);
            Logger::Console(pPlayer, "Removed muted Player: " + pCache.Name + " [" + pCache.SteamID + "]");   
            return true;
        }
        else
            return false;
    }

    bool GetBanList( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        array<string> aryTemp = IO::FileReader(Config::General::szRootPath + Config::General::szFilePath);
        Logger::Console(pPlayer, "#/ID/  /IP/  /Name/  /Reason/  /Time/");
        for(uint i = 0; i < aryTemp.length(); i++)
        {
            Logger::Console(pPlayer, aryTemp[i].Replace("\t", "  "));
        }
        Logger::Console(pPlayer, "#/ID/  /IP/  /Name/  /Reason/  /Time/");
        return true;
    }

    bool GetGargList( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        array<string> aryTemp = IO::FileReader(Config::General::szRootPath + Config::General::szMuteFilePath);
        Logger::Console(pPlayer, "#/ID/  /IP/  /Name/  /Reason/  /Time/");
        for(uint i = 0; i < aryTemp.length(); i++)
        {
            Logger::Console(pPlayer, aryTemp[i].Replace("\t", "  "));
        }
        Logger::Console(pPlayer, "#/ID/  /IP/  /Name/  /Reason/  /Time/");

        for(uint i = 0; i < Player::aryGargList.length(); i++)
        {
            Logger::Console(pPlayer, Player::aryGargList[i].SteamID);
        }

        return true;
    }

    bool GetLogList( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        string szTemp = Config::Log::szFormmat;
        szTemp = szTemp.Replace("%time%", "/Time/").Replace("%tag%", "/Tag/").Replace("%id%", "/SteamID").Replace("%ip%", "/IP/").Replace("%player%", "/Name/").Replace("%content%", "/Content/").Replace("\t", "  ");
        array<string> aryTemp = IO::FileReader(Config::General::szRootPath + Config::Log::szLogPath);
        Logger::Console(pPlayer, szTemp);
        for(uint i = 0; i < aryTemp.length(); i++)
        {
            Logger::Console(pPlayer, aryTemp[i].Replace("\t", "  "));
        }
        Logger::Console(pPlayer, szTemp);
        return true;
    }

    bool DumpPlayerInfo( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        Logger::Console(pPlayer, "#/Name/  /ID/  /IP/ /Said/  /Detected/");
        for(uint i = 0; i < Player::aryCachePlayerList.length(); i++)
        {
            Logger::Console(pPlayer, Player::aryCachePlayerList[i].Name + "  "  + 
                                    Player::aryCachePlayerList[i].SteamID + "  " +
                                    Player::aryCachePlayerList[i].IP + "  "  +
                                    Player::aryCachePlayerList[i].Said + "  "  +
                                    Player::aryCachePlayerList[i].Detect);
        }
        Logger::Console(pPlayer, "#/Name/  /ID/  /IP/  /Said/  /Detected/");
        return true;
    }

    bool DumpInfoToFile( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        string szPath = "scripts/plugins/store/chatengine/ChatEngine_DumpInfo_";
        if(pArgs[1] != "")
            szPath += pArgs[1];
        else
            szPath += Utility::GetTime("%Y-%m-%d-%H-%M-%S");
        szPath += ".txt";

        string szTemp = "";
        for(uint i = 0; i < Player::aryCachePlayerList.length(); i++)
        {
            szTemp += Player::aryCachePlayerList[i].Name + "  "  + 
                                    Player::aryCachePlayerList[i].SteamID + "  " +
                                    Player::aryCachePlayerList[i].IP + "  "  +
                                    Player::aryCachePlayerList[i].Said + "  "  +
                                    Player::aryCachePlayerList[i].Detect + "\n";
        }
        Logger::Console(pPlayer, "Saving dumpinfo into " + szPath + "...");
        return IO::FileWriter(szPath, szTemp);
    }

    bool GetKeyWords( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        Logger::Console(pPlayer, Config::KeyWord::szKeyWordHelp);
        string szTemp = "";
        for(uint i = 0; i < KeywordReplace::aryKeyList.length(); i++)
        {
            if(!KeywordReplace::aryKeyList[i].IsEmpty())
            {
                CKeyWord@ pKey = cast<CKeyWord@>(KeywordReplace::aryKeyList[i].Get());
                szTemp += pKey.Name + " ";
            }
        }
        Logger::Console(pPlayer, szTemp);
        return true;
    }

    bool GetSounds( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        Logger::Console(pPlayer, "可用Trigger有:");
        Logger::Console(pPlayer, "------------------------");
        string sMessage = "";
        for (uint i = 1; i < ChatSound::g_Coinfig.aryTriggerList.length() + 1;i++) 
        {
            sMessage += ChatSound::g_Coinfig.aryTriggerList[i-1].Name + " | ";
            if (i % 5 == 0) 
            {
                sMessage.Resize(sMessage.Length() -2);
                Logger::Console(pPlayer, sMessage);
                sMessage = "";
            }
        }
        if (sMessage.Length() > 2) 
        {
            sMessage.Resize(sMessage.Length() -2);
            Logger::Console(pPlayer, sMessage);
        }
        Logger::Console(pPlayer, "");
        return true;
    }

    bool SetPitch( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        ChatSound::PlayerSoundItem@ pSoundItem = ChatSound::GetPlayerSoundItem(szSteamId);
        if(pSoundItem is null)
        {
            @pSoundItem = ChatSound::PlayerSoundItem(szSteamId);
            ChatSound::g_Coinfig.aryPlayerSoundList.insertLast(pSoundItem);
        }
        int i = Math.clamp(ChatSound::g_Coinfig.iMin, ChatSound::g_Coinfig.iMax, atoi(pArgs[1]));
        pSoundItem.Pitch = i;
        Logger::Console(pPlayer, "已设置音调至" + i);
        return true;
    }

    bool AddBanListMnually( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        if(pArgs[1] == "")
            return false;
        
        string szID = pArgs[1];
        string szIP = pArgs[2].IsEmpty() ? "0.0.0.0" : pArgs[2];
        string szName = pArgs[3].IsEmpty() ? "Unkown" : pArgs[3];
        string szReason = pArgs[4].IsEmpty() ? "Banned" : pArgs[4];
        CCachePlayer@ pCache = CCachePlayer(szID, szIP, szName, szReason);
        Logger::Console(pPlayer, "Added Banned Player: " + pCache.Name + " [" + pCache.SteamID + "]");
        Player::NewBan(pCache);
        return true;
    }
}