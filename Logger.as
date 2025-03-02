namespace Logger
{
    string szSayLogSavePath = "";
    void GetSayLogSavePath()
    {
        szSayLogSavePath = g_EngineFuncs.CVarGetString("logsdir");
        szSayLogSavePath = szSayLogSavePath.Replace("/", "-").Replace("\\", "-");
    }
    //专为封禁使用的Log
    void Warn(string szTag, CCachePlayer@ pCache, string szContent)
    {
        string szTemp = Config::Log::szFormmat;
        IO::FileWriter(Config::General::szRootPath + Config::Log::szLogPath, 
                    szTemp.Replace("%time%", Utility::GetTime()).Replace("%tag%", szTag).Replace("%id%", pCache.SteamID).Replace("%ip%", pCache.IP).Replace("%player%", pCache.Name).Replace("%content%", szContent),
                    OpenFile::APPEND);
        Log( "Detetcted. [" + Utility::GetTime() + "] - " + szTag + "-" + pCache.Name + "-" + pCache.SteamID + ":" + szContent + "\n");
    }

    void SayLog(string content)
    {
        DateTime dt;
        string szPath = Config::General::szRootPath + Config::General::szChatLogFilePath + 
                szSayLogSavePath + (szSayLogSavePath == "" ? "" : "-") + 
                dt.GetYear() + "-" + dt.GetMonth() + "-" + dt.GetDayOfMonth() + ".log";
        File @pFile = g_FileSystem.OpenFile( szPath , OpenFile::APPEND );
        if(pFile is null)
            @pFile = g_FileSystem.OpenFile( szPath , OpenFile::WRITE );
        if (pFile !is null && pFile.IsOpen())
        {
            pFile.Write( content + "\n");
            pFile.Close();	
        }
        else
            Log("[ERROR]Cant write in chat log " + szPath + " - " + content);
    }

    void WriteLine(CBasePlayer@ pPlayer, string szContent, bool bChat = false)
    {
        if(bChat)
            Chat(pPlayer, szContent);
        else
            Console(pPlayer, szContent);
    }
    void Log(string szContent)
    {
        g_Log.PrintF( "[" + g_Module.GetModuleName() + "] " + szContent + "\n");
    }
    void WriteLine(string szContent)
    {
        g_Game.AlertMessage(at_console, szContent + "\n");
    }
    void Say(CBasePlayer@ pPlayer, string szContent)
    {
        g_PlayerFuncs.SayText(pPlayer, szContent + "\n");
    }

    void Say(string szContent)
    {
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, szContent + "\n");
    }

    void Chat(CBasePlayer@ pPlayer, string szContent)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, szContent + "\n");
    }

    void Chat(CBasePlayer@ pPlayer)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "\n");
    }

    void Console(CBasePlayer@ pPlayer, string szContent)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, szContent + "\n");
    }

    void Console(CBasePlayer@ pPlayer, array<string> szContent)
    {
        for(uint i = 0; i < szContent.length(); i++)
        {
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, szContent[i] + "\n");
        }
    }

    void Console(CBasePlayer@ pPlayer)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n");
    }

    void Console(string szContent)
    {
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, szContent + "\n");
    }

    void Center(CBasePlayer@ pPlayer, string szContent)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, szContent + "\n");
    }
}