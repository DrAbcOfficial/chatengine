namespace Command
{
    array<CHandlePackage@> aryCmdList = {};

    funcdef bool CmdCallback( CBasePlayer@, const CCommand@, const CClinetCmd@ );

    void Register( string _szName, string _szHelpInfo, string szDescribeInfo ,string szReturnInfo, CmdCallback@ pCallback, ConCommandFlags_t iAdminLevel = ConCommandFlag::None )
    {
		string szName = "cte_" + _szName;
		string szHelpInfo = szName + " " + _szHelpInfo;
		
        CClinetCmd command;
            command.Name = "." + szName;
            command.HelpInfo = "." + szHelpInfo;
            command.DescribeInfo = szDescribeInfo;
            command.ReturnInfo = szReturnInfo;
            command.AdminLevel = iAdminLevel;
            @command.ClientCallback = pCallback;
            @command.ClientCommand = CClientCommand(szName, szHelpInfo, @HandelCallback, iAdminLevel);

        aryCmdList.insertLast(CHandlePackage(@command));

        Logger::WriteLine(Utility::SnipLaunguage(Config::Launguage::szCommandRegisted, szName));
    }

    CHandlePackage@ GetCommand( string szName )
    {
        for(uint i = 0; i < aryCmdList.length(); i++)
        {
            if(cast<CClinetCmd@>(aryCmdList[i].Get()).Name == szName)
                return aryCmdList[i];
        }
        
        return CHandlePackage();
    }

    void HandelCallback( const CCommand@ Argments )
    { 
        CHandlePackage@ pPackage = GetCommand(Argments[0]);
        
        if(pPackage.IsEmpty())
        {
            Logger::Log(Utility::SnipLaunguage(Config::Launguage::szCommandEmpty, Argments[0]));
            return;
        }

        CClinetCmd@ pCmd = cast<CClinetCmd@>(pPackage.Get());
        
        if( pCmd.IsEmpty() )
        {
            Logger::Log( Utility::SnipLaunguage(Config::Launguage::szCommandCallbackEmpty, Argments[0]));
            return;
        }
        
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        if(g_PlayerFuncs.AdminLevel(pPlayer) < int(pCmd.AdminLevel))
        {
            Logger::Console(pPlayer, Utility::SnipLaunguage(Config::Launguage::szCommandForbidden, Utility::GetAdminLevelString(pCmd.AdminLevel)));
            return;
        }
        
        if(pCmd.ClientCallback(pPlayer, Argments, pCmd))
        {
            Logger::Console(pPlayer, Utility::SnipLaunguage(Config::Launguage::szCommandExeced, pCmd.Name));
            if(pCmd.ReturnInfo != "")
                Logger::Console(pPlayer, pCmd.ReturnInfo);
        }
        else
        {
            Logger::Console(pPlayer, Utility::SnipLaunguage(Config::Launguage::szCommandFailed, pCmd.Name));
            Logger::Console(pPlayer, "[" + pCmd.Name + "]:" + pCmd.HelpInfo);
        }
    }
}