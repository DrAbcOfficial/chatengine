namespace Player
{
    array<CCachePlayer@> aryCachePlayerList = {};
    array<CCachePlayer@> aryBanList = {};
    array<CCachePlayer@> aryGargList = {};

    CCachePlayer@ GetCache(CBasePlayer@ pPlayer)
    {
        const string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        //检查是否在列表内
        for(uint i = 0; i < Player::aryCachePlayerList.length(); i++)
        {
            if(szSteamId == Player::aryCachePlayerList[i].SteamID)
                return @Player::aryCachePlayerList[i];
        }
        return null;
    }

    CCachePlayer@ GetCache(string szSteamId)
    {
        //检查是否在列表内
        for(uint i = 0; i < Player::aryCachePlayerList.length(); i++)
        {
            if(szSteamId == Player::aryCachePlayerList[i].SteamID)
                return @Player::aryCachePlayerList[i];
        }
        return null;
    }

    CCachePlayer@ GetBanCache(string szSteamId)
    {
        //检查是否在列表内
        for(uint i = 0; i < Player::aryBanList.length(); i++)
        {
            if(szSteamId == Player::aryBanList[i].SteamID)
                return @Player::aryBanList[i];
        }
        return null;
    }

    CCachePlayer@ GetGargCache(string szSteamId)
    {
        //检查是否在列表内
        for(uint i = 0; i < Player::aryGargList.length(); i++)
        {
            if(szSteamId == Player::aryGargList[i].SteamID)
                return @Player::aryGargList[i];
        }
        return null;
    }

    void SayNetWorkMessage(CBasePlayer@ pPlayer, string szContent)
    {
        NetworkMessage m(MSG_ALL, NetworkMessages::SayText, null);
            m.WriteByte(pPlayer.entindex());
            m.WriteByte(2); // tell the client to color the player name according to team
            m.WriteString(szContent);
        m.End();
    }

    void SayNetWorkMessage(CBasePlayer@ pPlayer, CBasePlayer@ pTarget, string szContent)
    {
        NetworkMessage m(MSG_ONE, NetworkMessages::SayText, pTarget.edict());
            m.WriteByte(pPlayer.entindex());
            m.WriteByte(2);
            m.WriteString(szContent);
        m.End();
    }

    void PlayerSay(CBasePlayer@ pPlayer, string szContent, string szRaw)
    {
        string szTemp = (pPlayer.IsAlive() ? "" : Config::Player::szDeadTag + " ") + string( pPlayer.pev.netname ) + ": " + szContent + "\n";
        string szId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

        if(Player::GetGargCache(szId) !is null)
            SayNetWorkMessage( pPlayer, pPlayer, KeywordReplace::Replace(pPlayer, szTemp) );
        else
            SayNetWorkMessage( pPlayer, KeywordReplace::Replace(pPlayer, szTemp) );

        Logger::SayLog( "Msg. " + Utility::GetTime() + " - " + string( pPlayer.pev.netname ) + "[" + szId + "] : " + szRaw );
    }

    void PlayerTeamSay(CBasePlayer@ pPlayer, string szContent, string szRaw)
    {
        string szTemp = Config::Player::szTeamTag + " " + (pPlayer.IsAlive() ? "" : Config::Player::szDeadTag + " ") + string( pPlayer.pev.netname ) + ": " + szContent + "\n";
        string szId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        if(Player::GetGargCache(szId) !is null)
        {
            SayNetWorkMessage( pPlayer, KeywordReplace::Replace(pPlayer, szTemp) );
            return;
        }
            
        for ( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ TempPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if (TempPlayer !is null && TempPlayer.IsConnected() && TempPlayer.Classify() == pPlayer.Classify())
                SayNetWorkMessage( pPlayer, TempPlayer, KeywordReplace::Replace(pPlayer, szTemp) );
        }
        Logger::SayLog( "Msg. in Team: " + pPlayer.Classify() + ". " + Utility::GetTime() + " - " + string( pPlayer.pev.netname ) + "[" + szId + "] : " + szRaw );
    }

    void NewBan(CCachePlayer@ pCache)
    {
        IO::BanListAppender(pCache);
        IO::BanListReader();
        Player::Ban(pCache.SteamID, Config::General::szBanReason);
        Player::aryCachePlayerList.removeAt(Player::aryCachePlayerList.find(pCache));
    }

    bool RemoveBan(CCachePlayer@ pCache)
    {
        IO::BanListReader();

        if(Player::aryBanList.find(pCache) >= 0)
        {
            Player::aryBanList.removeAt(Player::aryBanList.find(pCache));
            Player::aryCachePlayerList.insertLast(pCache);

            IO::BanListSaver();
            return true;
        }
        return false;
    }

    void NewGarg(CCachePlayer@ pCache)
    {
        IO::BanListAppender(pCache, Config::General::szRootPath + Config::General::szMuteFilePath);
        IO::BanListReader(aryGargList, Config::General::szRootPath + Config::General::szMuteFilePath);
    }

    bool RemoveGarg(CCachePlayer@ pCache)
    {
        IO::BanListReader(aryGargList, Config::General::szRootPath + Config::General::szMuteFilePath);

        if(Player::aryGargList.find(pCache) >= 0)
        {
            Player::aryGargList.removeAt(Player::aryGargList.find(pCache));
            IO::BanListSaver(aryGargList, Config::General::szRootPath + Config::General::szMuteFilePath);
            return true;
        }
        return false;
    }

    void Kick(string steamid, string szReason)
    {
        g_EngineFuncs.ServerCommand("kick #" + steamid + " \"" + Config::Launguage::szGeneralKicked + ":" + szReason + " \"\n");
    }

    void Kick(CBasePlayer@ pPlayer, string szReason)
    {
        if(@pPlayer is null)
            return;

        g_EngineFuncs.ServerCommand("kick #" + g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()) + " \"" + Config::Launguage::szGeneralKicked + ":" + szReason + " \"\n");
    }

    void Ban(string steamid, string szReason)
    {
        g_EngineFuncs.ServerCommand("kick #" + steamid + " \"" + Config::Launguage::szGeneralBaned + ":" + szReason + " \"\n");
    }

    void Ban(CBasePlayer@ pPlayer, string szReason)
    {
        if(@pPlayer is null)
            return;

        g_EngineFuncs.ServerCommand("kick #" + g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()) + " \"" + Config::Launguage::szGeneralBaned + ":" + szReason + " \"\n");
    }
}