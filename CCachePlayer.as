class CCachePlayer
{
    CCachePlayer(string _SteamID, string _IP, string _Name, string _Reason)
    {
        SteamID = _SteamID;
        IP = _IP;
        Name = _Name;
        Reason = _Reason;
    }

    string SteamID;
    string IP;
    string Name;
    string Reason;
    uint64 Said = 0;
    int Detect = 0;

    bool opEquals(CCachePlayer@ pOther)
    {
        return this.SteamID == pOther.SteamID;
    }

    bool opEquals(string pOther)
    {
        return this.SteamID == pOther;
    }

    string ToString()
    {
        return SteamID + "\t" + IP + "\t" + Name + "\t" + Reason;
    }
}