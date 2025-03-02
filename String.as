namespace String
{
    string TrimChat(string inStr)
    {
        //转换为小写
        string szTemp = inStr.ToLowercase();
        //去除忽略字符
        for(uint i = 0; i < Config::General::aryIgnoreChar.length(); i++)
        {
            szTemp = szTemp.Replace(Config::General::aryIgnoreChar[i], "");
        }
        return szTemp;
    }

    string PadSpace(uint uiLength, string&in inStr, string ptrChar = " ")
    {
        string szTemp = inStr;
        for(uint i = inStr.Length(); i < uiLength; i++)
        {
            szTemp += ptrChar;
        }
        return szTemp;
    }
    
    string PadMute(string&in inStr)
    {
        string tempStr = "";
        for(uint i = 0; i < inStr.Length(); i++)
        {
            tempStr += Config::General::szMuteChar;
        }
        return tempStr;
    }

    string TimePadZero( int HrMinSec )
    {
        string TempString = string( HrMinSec );
        
        if ( TempString.Length() == 1 )
        {
            return "0" + TempString;
        }
        
        return TempString;
    }

    int CheckString(string Argumens, uint uiMatchType = 1)
    {
        string tempStr = TrimChat(Argumens);

        bool  bFlag = false;    //敏感词结束标识位：用于敏感词只有1位的情况  
        int iMatchFlag = 0;     //匹配标识数默认为0 
        int iDetectFlag = 0;
        string cWord = 0;  
        CDFA@ pNowMap = Config::General::pKeyWords;
        string szSencor = "";

        for(uint i = 0; i < tempStr.Length(); i++)
        {  
            cWord = tempStr[i];
            CDFA@ pDfa = pNowMap.Get(cWord);
            if(@pDfa !is null)
            {
                szSencor += cWord;
                @pNowMap = @pDfa;
                //存在，则判断是否为最后一个
                //找到相应key，匹配标识+1
                iMatchFlag++;
                //如果为最后一个匹配规则,结束循环，返回匹配标识数  
                if(pNowMap.IsEnd())
                {
                     //结束标志位为true
                    bFlag = true;
                    iDetectFlag++;
                    //最小规则，直接返回,最大规则还需继续查找
                    if(uiMatchType == 0)
                        break;  
                }  
            }
            //不存在，直接返回  
            else
                break;
        }  
        if(iMatchFlag < 2 && !bFlag)   
            iMatchFlag = 0;
        if(iDetectFlag >= 1)
            Logger::Log("检测词: " + tempStr + "|长度: "+ tempStr.Length() +"|检测节点: " + iMatchFlag + "|终节点: " + iDetectFlag + "敏感词:" + szSencor);
        return iDetectFlag;  
    }
}