namespace ChatSound
{
    dictionary dicStaticLog = {};

    void Add(string szKey)
    {
        //dicStaticLog[szKey] = int(dicStaticLog[szKey]) + 1;
    }

    void Init()
    {
        // for(uint i = 0; i < g_Coinfig.aryTriggerList.length();i++)
        // {
        //     if(!dicStaticLog.exists(g_Coinfig.aryTriggerList[i].Name))
        //         dicStaticLog[g_Coinfig.aryTriggerList[i].Name] = 0;
        // }
    }

    void CleanData()
    {
        // dicStaticLog = {};
        // Init();
    }

    bool MapOutData()
    {
        return false;
        // string szPath = "scripts/plugins/store/chatengine/ChatEngine_Chatsound_Static.csv";
        // string szTemp = "";
        // array<string>@ aryKeys = dicStaticLog.getKeys();
        // for(uint i = 0; i < aryKeys.length(); i++)
        // {
        //     szTemp += aryKeys[i] + ","+ string(int(dicStaticLog[aryKeys[i]])) + "\n";
        // }
        // return IO::FileWriter(szPath, szTemp, OpenFile::APPEND);
    }

    bool Out( CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd)
    {
        return false;
        // string szPath = "scripts/plugins/store/chatengine/ChatEngine_Chatsound_Static";
        // if(pArgs[1] != "")
        //     szPath += pArgs[1];
        // else
        //     szPath += Utility::GetTime("%Y-%m-%d-%H-%M-%S");
        // szPath += ".csv";

        // string szTemp = "";
        // array<string>@ aryKeys = dicStaticLog.getKeys();
        // for(uint i = 0; i < aryKeys.length(); i++)
        // {
        //     szTemp += aryKeys[i] + ","+ string(int(dicStaticLog[aryKeys[i]])) + "\n";
        // }
        // Logger::Console(pPlayer, "Saving statics into " + szPath + "...");
        // return IO::FileWriter(szPath, szTemp);
    }
}