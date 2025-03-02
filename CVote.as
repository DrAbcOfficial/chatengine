
//Vote类
//实例化或继承使用
funcdef void CVoteCallBack( CVote@, bool, int );
funcdef void CVoteBlockCallBack(CVote@, float);

class CVote
{
    private Vote@ pVote = null;
    CBasePlayer@ pOwner = null; 
    CVoteCallBack@ pYes = null;
    CVoteCallBack@ pNo = null;
    CVoteBlockCallBack@ pBlock = null;
    dictionary dicArgument = {};

    CVote( string&in _Name, string&in _Describe, CBasePlayer@ pPlayer = null)
    {
        float flVoteTime = g_EngineFuncs.CVarGetFloat( "mp_votetimecheck" );
        float flPercentage = g_EngineFuncs.CVarGetFloat( "mp_voteclassicmoderequired" );

        @this.pVote = @Vote( _Name, _Describe, flVoteTime, flPercentage );
        this.pVote.SetVoteEndCallback(function(Vote@ pVote, bool bResult, int iVoters){
            CVote@ cVote = GetVoteClass(pVote);
            if(!bResult)
            {
                if(cVote.pNo !is null)
                    cVote.pNo(cVote, bResult, iVoters);
            }
            else
            {
                if(cVote.pYes !is null)
                    cVote.pYes(cVote, bResult, iVoters);
            }
            //从词典中删除该投票
            dicVotes.delete(pVote.GetName());
            g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "投票: " + cVote.Name + (bResult ? "已通过" : "未通过") + "\n");
        });
        this.pVote.SetVoteBlockedCallback(function(Vote@ pVote, float flTime){
            CVote@ cVote = GetVoteClass(pVote);
            if(cVote.pBlock !is null)
                cVote.pBlock(cVote, flTime);
            g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "投票: " + cVote.Name + "已阻挡\n");
        });

        if(pPlayer !is null)
            @this.pOwner = @pPlayer;
    }

    Vote@ getVote()
    {
        return pVote;
    }

    string Name
	{
		get const{ return this.pVote.GetName();}
	}

    any@ setOwner
	{
        set { this.pVote.SetUserData(value); }
	}

    void setCallBack(CVoteCallBack@ _pYes, CVoteCallBack@ _pNo = null, CVoteBlockCallBack@ _pBlock = null)
    {
	    @this.pYes = @_pYes;
        if(_pNo !is null)
            @this.pNo = @_pNo;
        if(_pBlock !is null)
            @this.pBlock = @_pBlock;
            
    }

    void setText(string&in szText, string&in szYes = "Yes", string&in szNo = "No")
    {
        this.pVote.SetVoteText(szText);
        this.pVote.SetYesText(szYes);
        this.pVote.SetNoText(szNo);
    }

    void Start()
    {
        this.pVote.Start();
    }

    //我不知道为什么你想把这玩意儿塞进数组还对他排序的
	int opCmp(CVote &in other) const
	{
		return this.Name.opCmp(other.Name);
	}
}

dictionary dicVotes;
dictionary dicPlayerTime;
const float flVoteCold = 45;

//由Vote获取CVote
CVote@ GetVoteClass(Vote@ pVote)
{
    return cast<CVote@>(dicVotes[pVote.GetName()]);
}

//创建新的投票
CVote@ CreatVote(string&in _Name, string&in _Describe, CBasePlayer@ pPlayer = null)
{
    if(pPlayer !is null)
    {
        string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        if(dicPlayerTime.exists(szSteamId))
        {
            float flTime = float(dicPlayerTime[szSteamId]);
            float flDes = g_Engine.time - flTime;
            if(flDes <=  flVoteCold)
            {
                Logger::Chat(pPlayer, "请等待至少" + int(flVoteCold - flDes) + "秒发起投票");
                return null;
            }
        }
        dicPlayerTime.set(szSteamId, g_Engine.time);   
    }
    CVote pVote(_Name, _Describe, pPlayer);
    dicVotes.set(_Name, @pVote);
    return pVote;
}