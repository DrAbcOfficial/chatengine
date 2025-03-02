namespace Utility
{
    string GetAdminLevelString(ConCommandFlags_t flag)
    {
        switch(int(flag))
        {
            case 0: return "None";
            case 1: return "Admin";
            case 2: return "Cheat/Server";
            default: return "Forbidden";
        }
    }

    string GetTime(string szFormat = "%Y:%m:%d-%H:%M:%S")
    {
        string szCurrentTime;
        DateTime time;
        time.Format(szCurrentTime, szFormat );
        return szCurrentTime;
    }

    string SnipLaunguage(string szOrigin, string szReplace)
    {
        return szOrigin.Replace("{0}", szReplace);
    }
}