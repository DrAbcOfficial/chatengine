namespace KeywordReplace
{
    funcdef string fundefKeyword ( CBasePlayer@, string );
    array<CHandlePackage@> aryKeyList = {};
    dictionary dic1337letter = {
        {"A", array<string> = {"4","/\\","@","^","aye","∂","/-\\","|-\\","q"}},
        {"B", array<string> = {"8","6","13","|3","ß","P>","|:","!3","(3","/3",")3","I3"}},
        {"C", array<string> = {"(","¢","<","[","©"}},
        {"D", array<string> = {"d","[)","|o",")","I>","|>","?","T)","|)","0","</","Đ"}},
        {"E", array<string> = {"3","&","€","£","є","ë","[-","|=-","Ǝ"}},
        {"F", array<string> = {"f","|=","ƒ","|#","ph","/=","Ƒ"}},
        {"G", array<string> = {"9","6","&","(_+","C-","gee","(γ,"}},
        {"H", array<string> = {"#","/-/","[-]","]-[",")-(","(-)",":-:","|~|","|-|","]~[","}{","]-[","?","}-{","hèch"}},
        {"I", array<string> = {"!","1","|","][","eye","3y3","]",":"}},
        {"J", array<string> = {"j","_|","_/","¿","</","(/","ʝ",";"}},
        {"K", array<string> = {"k","|<","X","|{","ɮ","<","|\\“"}},
        {"L", array<string> = {"1","|_","1_","ℓ","|","][_,","£"}},
        {"M", array<string> = {"m","|v|","[V]","{V}","|\\/|","/\\/\\","(u)","(V)","(\\/)","/|\\","^^","/|/|","//.",".\\\\","/^^\\","///","|^^|",".\\\\", "N\\"}},
        {"N", array<string> = {"~","|\\|","^/","|V","/\\/","[\\]","<\\>","{\\}","]\\[","//","^","[]","/V","₪"}},
        {"O", array<string> = {"0","()","oh","[]","¤","°","([])"}},
        {"P", array<string> = {"p","9","|*","|o","|º","|^(o)","|>","\"|\"\"\"","[]D","|̊","|7","?","/*","¶","/*"}},
        {"Q", array<string> = {"q","(_,)","()_","0_","°|","<|","0."}},
        {"R", array<string> = {"r","|2","2","|?","/2","|^","lz","®","[z","12","Я","ʁ","|²",".-",",-","|°\\"}},
        {"S", array<string> = {"5","$","z","§","ehs","es","_/¯"}},
        {"T", array<string> = {"7","+","-|-","1","']['","†","|²","¯|¯"}},
        {"U", array<string> = {"u","(_)","|_|","v","L|","µ","J"}},
        {"V", array<string> = {"v","\\/","1/","|/","o|o","▼"}},
        {"W", array<string> = {"w","\\/\\/","vv","'//","\\\\`","\\^/","(n)","\\V/","\\X/","\\|/","\\_|_/","\\_:_/","?","?","`^/","\\./"}},
        {"X", array<string> = {"*","><","Ж","}{","ecks","×",")("}},
        {"Y", array<string> = {"y","7","j","`/","Ψ","φ","λ","Ч","¥","'/"}},
        {"Z", array<string> = {"2","≥","=/=","7_","~/_","%",">_",">_","-\\_","'/_"}},
        {"0", array<string> = {"O", "D"}},
        {"1", array<string> = {"I", "L"}},
        {"2", array<string> = {"Z"}},
        {"3", array<string> = {"E"}},
        {"4", array<string> = {"H", "A"}},
        {"5", array<string> = {"S"}},
        {"6", array<string> = {"b", "G"}},
        {"7", array<string> = {"T", "L", "J"}},
        {"8", array<string> = {"B"}},
        {"9", array<string> = {"P"}}
    };

    bool Register(string key, fundefKeyword@ func)
    {
        if(Exists(key))
            return false;

        CKeyWord command;
            command.Name = "{" + key + "}";
            @command.Func = @func;
        aryKeyList.insertLast(CHandlePackage(@command));
        Logger::WriteLine(Utility::SnipLaunguage(Config::KeyWord::szKeywordRegisted, key));
        return true;
    }

    bool Exists(string key)
    {
        for(uint i = 0; i < aryKeyList.length(); i++)
        {
            CKeyWord@ pKey = cast<CKeyWord@>(aryKeyList[i].Get());
            if(pKey.Name == key)
                return true;
        }
        return false;
    }

    string GetLevelReplace(CBasePlayer@ pPlayer)
    {
        CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByClassname(@pEntity, "info_exp_infobank");
        if(pEntity !is null)
        {
            pEntity.Use(@pPlayer, null, USE_ON);
            return "[" + pEntity.pev.button + "]";
        }
        return "";
    }

    string Replace(CBasePlayer@ pPlayer, string szContent)
    {
        string szTemp = "";
        int iFlag = -1;
        if(szContent.Find("{n00b}") != String::INVALID_INDEX)
            iFlag = 0;
        if(szContent.Find("{1337}") != String::INVALID_INDEX)
            iFlag = 1;
        if(iFlag > -1)
        {
            string sz1337 = szContent.Replace((pPlayer.IsAlive() ? "" : Config::Player::szDeadTag + " ") + string( pPlayer.pev.netname ) + ": ", "").Replace("{n00b}", "").Replace("{1337}", "");
            for(uint i = 0; i < sz1337.Length();i++)
            {
                if(dic1337letter.exists(toupper(sz1337[i])))
                {
                    array<string>@ aryTemp = cast<array<string>@>(dic1337letter[toupper(sz1337[i])]);
                    szTemp += aryTemp[iFlag == 0 ? 0 : Math.RandomLong(0, aryTemp.length() - 1)];
                }
                else
                    szTemp += sz1337[i];
            }
            szTemp = (pPlayer.IsAlive() ? "" : Config::Player::szDeadTag + " ") + GetLevelReplace(pPlayer) + string( pPlayer.pev.netname ) + ": " + szTemp;
        }
        else
            szTemp = szContent;
        for(uint i = 0; i < aryKeyList.length(); i++)
        {
            CKeyWord@ pKey = cast<CKeyWord@>(aryKeyList[i].Get());
            if(szTemp.Find(pKey.Name) != String::INVALID_INDEX)
                szTemp.Replace(pKey.Name, pKey.Func(pPlayer, szContent));
        }
        return szTemp;
    }
}

namespace KeywordReplaceFunc
{
    string Time(CBasePlayer@ _, string __)
    {
        return Utility::GetTime();
    }

    string Pos(CBasePlayer@ pPlayer, string _)
    {
        return "[" + int(pPlayer.pev.origin.x) + ", " + int(pPlayer.pev.origin.y) + ", " + int(pPlayer.pev.origin.z) + "]";
    }

    string Weapon(CBasePlayer@ pPlayer, string _)
    {
        CBaseEntity@ pInflictor = pPlayer.m_hActiveItem.GetEntity();
		if(pInflictor !is null)
            return string(pInflictor.pev.classname).Replace("weapon_", "");
        return "Null";
    }

    string HP(CBasePlayer@ pPlayer, string _)
    {
        return string(int(pPlayer.pev.health));
    }

    string AP(CBasePlayer@ pPlayer, string _)
    {
        return string(int(pPlayer.pev.armorvalue));
    }

    string Texture(CBasePlayer@ pPlayer, string _)
    {
        return pPlayer.m_szTextureName();
    }

    string Death(CBasePlayer@ pPlayer, string _)
    {
        return string(pPlayer.m_iDeaths);
    }

    string Frags(CBasePlayer@ pPlayer, string _)
    {
        return string(int(pPlayer.pev.frags));
    }
}