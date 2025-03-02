#include "ChatSound_Static"

namespace ChatSound
{
    Config g_Coinfig;
    array<CCachePlayer@> aryMuter = {};

    class Config
    {
        string szSpriteName = "sprites/chatspr/voiceicon.spr";
        string szSaveSpriteName = "sprites/saveme.spr";
        string szFilePath = "scripts/plugins/ChatSound.txt";
        float flDelay = 3.5;
        int iDefaultPitch = 100;
        int iMin = 100;
        int iMax = 200;
        array<TriggerItem@> aryTriggerList = {};
        array<PlayerSoundItem@> aryPlayerSoundList = {};
    }

    class PlayerSoundItem
    {
        PlayerSoundItem(string _SteamID)
        {
            SteamID = _SteamID;
            Pitch = g_Coinfig.iDefaultPitch;
            ChatTime = 0;
        }
        string SteamID;
        int Pitch;
        float ChatTime;
    }

    class TriggerItem
    {
        TriggerItem(string _Name, string _Path, int _Impulse)
        {
            Name = _Name;
            Path = _Path;
            Impulse = _Impulse;
        }
        string Name;
        string Path;
        string SprPath;
        int Impulse;
    }

    bool PlayChatSound(CBasePlayer@ pPlayer, const CCommand@ pArguments)
    {
        array<string> aryTemp = {};
        for(int i = 0; i < pArguments.ArgC(); i++)
        {
            aryTemp.insertLast(pArguments[i]);
        }
        return PlayChatSound(@pPlayer, @aryTemp);
    }

    bool PlayChatSound(CBasePlayer@ pPlayer, array<string>@ pArguments)
    {
        string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        CCachePlayer@ pCache = Player::GetCache(szSteamId);
        if(aryMuter.find(@pCache) >= 0)
        {
            Logger::Center(pPlayer, "You are muted becasue of spaming. :D");
            return false;
        }
        PlayerSoundItem@ pSoundItem = GetPlayerSoundItem(szSteamId);
        if(pSoundItem is null)
        {
            @pSoundItem = PlayerSoundItem(szSteamId);
            g_Coinfig.aryPlayerSoundList.insertLast(pSoundItem);
        }
        TriggerItem@ pItem = GetTrigger(pArguments[0]);
        if(pItem !is null)
        {
            Add(pItem.Name);
            int iTempPitch = pSoundItem.Pitch;
            if(pArguments.length() > 1)
                iTempPitch = Math.clamp(g_Coinfig.iMin, g_Coinfig.iMax, atoi(pArguments[1]));

			float d = g_EngineFuncs.Time() - pSoundItem.ChatTime;

			if (d < g_Coinfig.flDelay) 
			{
				string w = string(g_Coinfig.flDelay - d);
                Logger::Center(pPlayer, "Wait " + w.SubString(0, w.Find(".") + 2) + " s");
                return false;
            }
            
            pSoundItem.ChatTime = g_EngineFuncs.Time();
            switch(pItem.Impulse)
            {
                case 0:pPlayer.ShowOverheadSprite(g_Coinfig.szSpriteName, 72.0f, 3.5f);break;
                case 1:pPlayer.ShowOverheadSprite(g_Coinfig.szSaveSpriteName, 72.0f, 3.5f);break;
                case 2:pPlayer.TakeDamage(g_EntityFuncs.Instance(0).pev, g_EntityFuncs.Instance(0).pev, 9999.9f, DMG_SHOCK);break;
                case 3:pPlayer.ShowOverheadSprite(pItem.SprPath, 72.0f, 3.5f);break;
                default:break;
            }
            g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, pItem.Path, 1.0f, 0.4f, 0, iTempPitch , 0, true, pPlayer.pev.origin);
            //NPC也能听见
            pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
        }
        return true;
    }

    PlayerSoundItem@ GetPlayerSoundItem(string szTemp)
    {
        for(uint i = 0; i < g_Coinfig.aryPlayerSoundList.length(); i++)
        {
            if(g_Coinfig.aryPlayerSoundList[i].SteamID == szTemp)
                return @g_Coinfig.aryPlayerSoundList[i];
        }
        return null;
    }

    TriggerItem@ GetTrigger(string szTemp)
    {
        for(uint i = 0; i < g_Coinfig.aryTriggerList.length(); i++)
        {
            if(g_Coinfig.aryTriggerList[i].Name == szTemp)
                return @g_Coinfig.aryTriggerList[i];
        }
        return null;
    }

    int IsTrigger(SayParameters@ pParams)
    {
        
        return GetTrigger(pParams.GetArguments()[0]) !is null ? 0 : 1;
    }

    void ReadSounds() 
    {
        File@ pFile = g_FileSystem.OpenFile(g_Coinfig.szFilePath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen()) 
        {
            while(!pFile.EOFReached()) 
            {
                string sLine;
                pFile.ReadLine(sLine);
                if (sLine.StartsWith("#") || sLine.IsEmpty())
                    continue;

                array<string> parsed = sLine.Split(" ");
                if (parsed.length() < 3)
                    continue;
                int num = atoi(parsed[2]);
                TriggerItem@ pItem = TriggerItem(parsed[0], parsed[1], num);
                if(num == 3 && parsed.length() > 3)
                    pItem.SprPath = parsed[3];

                g_Coinfig.aryTriggerList.insertLast(pItem);
            }
            pFile.Close();
        }
    }

    void Precache()
    {
        g_Game.PrecacheModel(g_Coinfig.szSpriteName);
        g_Game.PrecacheGeneric(g_Coinfig.szSpriteName);

        g_Game.PrecacheModel(g_Coinfig.szSaveSpriteName);
        g_Game.PrecacheGeneric(g_Coinfig.szSaveSpriteName);

        for(uint i = 0; i < g_Coinfig.aryTriggerList.length(); i++)
        {
            g_SoundSystem.PrecacheSound(g_Coinfig.aryTriggerList[i].Path);
            g_Game.PrecacheGeneric("sound/" + g_Coinfig.aryTriggerList[i].Path);

            if(g_Coinfig.aryTriggerList[i].SprPath != "")
            {
                g_Game.PrecacheModel(g_Coinfig.aryTriggerList[i].SprPath);
                g_Game.PrecacheGeneric(g_Coinfig.aryTriggerList[i].SprPath);
            }
        }
    }

    CTextMenu@ pMenu = CTextMenu(function(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem)
    {
        if(mItem !is null && pPlayer !is null){
            PlayChatSound(@pPlayer, {mItem.m_szName});
        }
    });

    void PluginInit()
    {
        for(uint i = 0; i < g_Coinfig.aryTriggerList.length(); i++)
        {
            pMenu.AddItem( g_Coinfig.aryTriggerList[i].Name, null);
        }
        pMenu.SetTitle("\r[Chatsound]\nStop SPAMING Little bastard");
    }

    void MapInit()
    {
        if(!pMenu.IsRegistered())
            pMenu.Register();
    }
}