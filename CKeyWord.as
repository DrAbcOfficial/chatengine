class CKeyWord
{
    private string szName = "";
    private KeywordReplace::fundefKeyword@ cmdKeyword;
        
    string Name
    {
        get const{ return szName;}
        set{ szName = value;}
    }
            
    KeywordReplace::fundefKeyword@ Func
    {
        get const{ return cmdKeyword;}
        set { @cmdKeyword = @value; }
    }
}