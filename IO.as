namespace IO
{
    bool BanListReader(array<CCachePlayer@>&out aryList = Player::aryBanList, string szPath = Config::General::szRootPath + Config::General::szFilePath)
    {
        array<CCachePlayer@> tempList = {};
        
        File @pFile = g_FileSystem.OpenFile(szPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen())
        {
            string szLine;
            while (!pFile.EOFReached())
            {
                pFile.ReadLine(szLine);
                //空白行
                if(szLine.IsEmpty())
                    continue;
                //注释
                if(szLine.StartsWith("//"))
                    continue;

                array<string> aryParse = szLine.Split("\t");
                //不足四项
                if(aryParse.length() < 4)
                    continue;
                
                tempList.insertLast(CCachePlayer(aryParse[0], aryParse[1], aryParse[2], aryParse[3]));
            }
            pFile.Close();
            aryList = tempList;
            return true;
        }
        return false;
    }

    void BanListSaver(array<CCachePlayer@> aryList = Player::aryBanList, string szPath = Config::General::szRootPath + Config::General::szFilePath)
    {
        string szTemp = "";
        for(uint i = 0; i < aryList.length(); i++)
        {
            szTemp += aryList[i].ToString() + "\t" + Utility::GetTime() + "\n";
        }
        FileWriter(szPath, szTemp);
    }

    void BanListAppender(CCachePlayer@ pCache, string szPath = Config::General::szRootPath + Config::General::szFilePath)
    {
        string szTemp = pCache.ToString() + "\t" + Utility::GetTime() + "\n";
        FileWriter(szPath, szTemp, OpenFile::APPEND);
    }

    array<string>@ FileReader(string szPath)
    {
        array<string> szTemp = {};
        File @pFile = g_FileSystem.OpenFile(szPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen())
        {
            string szLine;
            while (!pFile.EOFReached())
            {
                pFile.ReadLine(szLine);
                szTemp.insertLast(szLine);
            }
            pFile.Close();
        }

        return szTemp;
    }

    string FileTotalReader(string szPath)
    {
        string szTemp = "";
        File @pFile = g_FileSystem.OpenFile(szPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen())
        {
            string szLine;
            while (!pFile.EOFReached())
            {
                pFile.ReadLine(szLine);
                szTemp += szLine + "\n";
            }
            pFile.Close();
        }
        return szTemp;
    }

    bool FileWriter(string szPath, string szContent, OpenFileFlags_t flag = OpenFile::WRITE)
    {
        File @pFile = g_FileSystem.OpenFile( szPath , flag );
        if ( pFile !is null && pFile.IsOpen())
        {
            pFile.Write( szContent );
            pFile.Close();	
            return true;
        }
        else
            return false;
    }

    bool FileWriter(string szPath, array<string> aryContent, OpenFileFlags_t flag = OpenFile::WRITE)
    {
        File @pFile = g_FileSystem.OpenFile( szPath , flag );
        if ( pFile !is null && pFile.IsOpen())
        {
            for(uint i = 0; i < aryContent.length(); i++)
            {
                pFile.Write( aryContent[i] );
            }
            pFile.Close();	
            return true;
        }
        else   
            return false;
    }

    //迭代初始化DFA词库
    void CensorDataBuilder(string szPath)
    {
        uint iCount = 0;
        uint iTerminal = 0;
        File @pFile = g_FileSystem.OpenFile(szPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen())
        {
            string szLine;
            while (!pFile.EOFReached())
            {
                pFile.ReadLine(szLine);
                szLine.Trim();
                if(szLine.IsEmpty())
                    continue;
                szLine.Replace(" ", "");

                CDFA@ pDic = Config::General::pKeyWords;
                for(uint i = 0; i < szLine.Length(); i++)
                {
                    string c = szLine[i];
                    CDFA@ pTemp = pDic.Get(c);
                    if(pTemp !is null)
                        @pDic = @pTemp;
                    else
                    {
                        CDFA@ pNew = CDFA(c);
                        pDic.Insert(pNew);
                        @pDic = @pNew;
                    }
                    iCount++;

                    if(i == szLine.Length()-1)
                    {
                        pDic.SetEnd();
                        iTerminal++;
                    } 
                }
            }
            pFile.Close();
        }
        Logger::WriteLine("已构造DFA树, 共: " + iCount + "节点. " + iTerminal + "终节点");
    }
}