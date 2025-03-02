class CDFA
{
    private string key = "";
    private array<CDFA@> aryChild = {};
    private bool isEnd = false;

    array<string>@ GetKeys()
    {
        array<string> aryKeys = {};
        for(uint i = 0; i < aryChild.length(); i++)
        {
            aryKeys.insertLast(aryChild[i].Key());
        }
        return aryKeys;
    }

    CDFA(string _key)
    {
        key = _key;
    }

    bool IsEnd()
    {
        return isEnd;
    }

    string Key()
    {
        return this.key;
    }

    CDFA@ Get(string _key)
    {
        for(uint i = 0; i < aryChild.length(); i++)
        {
            if(aryChild[i].key == _key)
                return aryChild[i];
        }
        return null;
    }

    bool Exists(string _key)
    {
        return Get(_key) !is null;
    }

    void SetEnd()
    {
        isEnd = true;
    }

    void Insert(CDFA@ pDfa)
    {
        aryChild.insertLast(@pDfa);
    }
}