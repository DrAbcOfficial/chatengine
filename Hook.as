namespace Hook
{
    HookReturnCode ClientConnected( edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason )
    {
        const string szSteamId = g_EngineFuncs.GetPlayerAuthId(pEntity);
        //检查是否已封禁
        for(uint i = 0; i < Player::aryBanList.length(); i++)
        {
            if(szSteamId == Player::aryBanList[i].SteamID)
            {
                Player::Ban(szSteamId, Config::General::szBanReason);
                return HOOK_HANDLED;
            }
        }

        CCachePlayer@ pCache  = Player::GetCache(szSteamId);
        if(@pCache is null)
        {
            @pCache = @CCachePlayer(szSteamId, szIPAddress, szPlayerName, "");
            Player::aryCachePlayerList.insertLast(@pCache);
        }
        //检查是否已达成封禁条件
        else if(pCache.Detect >= Config::General::iGameMaxLimite)
        {
            Logger::Warn( Config::Log::szLogBanHeader, pCache, szPlayerName );
            Player::NewBan(pCache);
            return HOOK_HANDLED;
        }
        else
        {
            pCache.Name = szPlayerName;
            pCache.SteamID = szSteamId;
            pCache.IP = szIPAddress;
        }

        int iChecked = String::CheckString(szPlayerName);
        //检查玩家名称
        if(iChecked > 0)
        {
            pCache.Detect += iChecked;
            Player::Kick(szSteamId, Config::General::szKickReason);

            bDisallowJoin = false;
            szRejectReason = Config::General::szKickReason;

            Logger::Warn( Config::Log::szLogName, pCache, szPlayerName );

            return HOOK_HANDLED;
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode ClientSay( SayParameters@ pParams )
    {
        string szTemp = pParams.GetCommand();
        szTemp.Trim();

        if(szTemp.IsEmpty() || szTemp == " " )
            return HOOK_CONTINUE;
            
        CBasePlayer@ pPlayer = pParams.GetPlayer();
        CCachePlayer@ pCache = Player::GetCache(pPlayer);
        pParams.set_ShouldHide( IsStarted );
        if(!IsStarted)
            return HOOK_CONTINUE;

        if(pCache is null)
            return HOOK_CONTINUE;
        
        if(szTemp.StartsWith("!") || szTemp.StartsWith("/"))
        {
            const CCommand@ pCommand = pParams.GetArguments();
            CHandlePackage@ pPackage = Command::GetCommand("." + pCommand[0].SubString(1));
            if(!pPackage.IsEmpty()){
                const CClinetCmd@ pCmd = cast<CClinetCmd@>(pPackage.Get());
                pCmd.ClientCallback( @pPlayer, @pCommand, @pCmd );
                Logger::Chat(@pPlayer, Utility::SnipLaunguage(Config::Launguage::szChatCommand, pCommand[0]));
                return HOOK_CONTINUE;
            }
        }

        int iDetectedNumber = String::CheckString(szTemp);
        if(iDetectedNumber > 0)
        {
            szTemp = Config::General::aryNiceWords[Math.RandomLong(0, Config::General::aryNiceWords.length() - 1)];
            Logger::Warn( Config::Log::szLogDetected, pCache, pParams.GetCommand() );
            pCache.Detect += iDetectedNumber;
        }
            
        //大于等于最大屏蔽次数，封禁
        if (iDetectedNumber >= Config::General::iMaxLimite)
        {
            Logger::Warn( Config::Log::szLogBanHeader, pCache, pParams.GetCommand() );
            Player::NewBan(pCache);
            return HOOK_HANDLED;
        }
        //快暴毙提醒
        if(float(pCache.Detect) / Config::General::iGameMaxLimite >= Config::General::flBanWarnLimite)
            Logger::Chat( @pPlayer, Utility::SnipLaunguage(Config::Launguage::szBanWarn, string(pCache.Detect) + "/" + string(Config::General::iGameMaxLimite)) );

        //最大容忍，封禁
        if (pCache.Detect >= Config::General::iGameMaxLimite)
        {
            Logger::Warn( Config::Log::szLogBanHeader, pCache, pParams.GetCommand() );
            Player::NewBan(pCache);
            return HOOK_HANDLED;
        }
        
        //通过检查，重置状态
        if(iDetectedNumber <= 0)
            szTemp = pParams.GetCommand();

        if(pCache.Said == Math.UINT64_MAX - 1)
            pCache.Said = 0;
        pCache.Said++;

        //Trigger
        switch(ChatSound::IsTrigger(pParams))
        {
            case 0:
            {
                if(!ChatSound::PlayChatSound(pPlayer, pParams.GetArguments()))
                    break;
            }
            default:
            {
                int iColor = 0;
                if(szTemp.Find("{yellow}") != String::INVALID_INDEX){
                    iColor = 18;
                    szTemp = szTemp.Replace("{yellow}", "");
                }
                else if(szTemp.Find("{red}") != String::INVALID_INDEX){
                    iColor = 17;
                    szTemp = szTemp.Replace("{red}", "");
                }  
                else if(szTemp.Find("{blue}") != String::INVALID_INDEX){
                    iColor = 16;
                    szTemp = szTemp.Replace("{blue}", "");
                }
                else if(szTemp.Find("{green}") != String::INVALID_INDEX){
                    iColor = 19;
                    szTemp = szTemp.Replace("{green}", "");
                } 
                int iClassify = -999;
                if(iColor != 0){
                    iClassify = pPlayer.Classify();
                    if (iClassify < 16 || iClassify > 19){
                        pPlayer.SetClassification(iColor);
                        pPlayer.SendScoreInfo();
                    }
                    else
                        iClassify = -999;
                }

                if( pParams.GetSayType() == CLIENTSAY_SAY )
                    Player::PlayerSay(pPlayer, szTemp, pParams.GetCommand());
                else
                    Player::PlayerTeamSay(pPlayer, szTemp, pParams.GetCommand());

                if(iColor != 0 && iClassify != -999){
                    pPlayer.SetClassification(iClassify);
                    g_Scheduler.SetTimeout("ResetPlayerInfo", 0.5f, EHandle(pPlayer));
                }
                break;
            }
        }
        return HOOK_CONTINUE;
    }

    void ResetPlayerInfo(EHandle ePlayer) {
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(ePlayer.GetEntity());
        if (pPlayer is null or !pPlayer.IsConnected())
            return;
        pPlayer.SendScoreInfo();
    }

    HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
    {
        CCachePlayer@ pCache = null;
        string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        //检查是否在列表内
        for(uint i = 0; i < Player::aryCachePlayerList.length(); i++)
        {
            if(steamId == Player::aryCachePlayerList[i].SteamID)
            {
                @pCache = @Player::aryCachePlayerList[i];
                break;
            }
        }

        if(@pCache !is null)
        {
            if(Config::General::uiDissconnetShowInfo > 0)
                Logger::Console(Utility::SnipLaunguage(Config::Launguage::szLeaveInfoHeader, pPlayer.pev.netname));

            switch(Config::General::uiDissconnetShowInfo)
            {
                case 0:break;
                case 2:Logger::Console(Utility::SnipLaunguage(Config::Launguage::szLeaveInfoIP, pCache.IP));
                case 1:Logger::Console(Utility::SnipLaunguage(Config::Launguage::szLeaveInfoID, pCache.SteamID));break;
                default:break;
            }
        }

        if(Config::General::bCleanExit)
            Player::aryCachePlayerList.removeAt(Player::aryCachePlayerList.find(pCache));

        return HOOK_CONTINUE;
    }
}