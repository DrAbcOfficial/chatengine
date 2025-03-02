namespace Config
{
    namespace General
    {
        //DFA词库HashMap
        CDFA pKeyWords("__#DFAROOT#_");
        //忽略字符
        const array<string> aryIgnoreChar = {
            " ", "\t", "\n", "#", "!", "@", "$", "%", "^", "&", "*", "(", ")", "_", "-", "+", 
            "=", ",", ".", "/", "?", ";", ":", "\"", "'", "[", "]", "{", "}", "\\", "|", "。", "•", "？", "~", "…", "Ⅱ"
        };
        //整句和谐替换词汇
        const array<string> aryNiceWords = {
            "我爱这个服务器",
            "我很享受游戏的时光",
            "这个服务器很有意思",
            "我喜欢你",
            "今天天气真好",
            "你今天看上去很棒",
            "你很有品位",
            "你的中文令人惊讶",
            "你人真好啊！",
            "你很有天赋",
            "我们十分为你骄傲",
            "鹤发银丝映日月，丹心热血沃新花",
            "你真幽默",
            "教师的春风，日日沐我心",
            "你干得非常好",
            "我对你的工作表示敬意",
            "你非常聪明",
            "一位好老师，胜过万卷书",
            "你的事业很成功",
            "你是最出色的",
            "你看上去帅呆了",
            "你看上去真精神",
            "你是那样地美，美得象一首抒情诗",
            "你全身充溢着少女的纯情和青春的风采",
            "你非常专业",
            "一天很短，开心了就笑，不开心了就过会儿再笑",
            "只要一想到你，我就很开心",
            "抽，是一种生活艺术；找抽，是一种生活态度",
            "看到喜欢的人主动找自己的时候最开心了",
            "人只能活一次，千万别活得太累：应该活得舒心，活得快乐，活得潇洒",
            "这辈子最开心的事莫过于有一群人惯着我让我各种嚣张各种得瑟",
            "我哭时，你难过;我笑时，你开心谢谢您",
            "对着太阳傻笑的一朵花：叫向日葵",
            "对于生活，我们往往是在度过，往往将最美好的愿望寄予终极",
            "今天很开心，和你一齐去了旅行，还是我们一年的纪念日",
            "爱我的，在乎我的，咒你们天天开心快乐",
            "今天也是好天气☆"
        };
        //和谐以后变成的字符
        const string szMuteChar = "X";
        //一句话出现多少个关键词封禁
        const int iMaxLimite = 3;
        //整场游戏总计多少个关键词封禁
        const int iGameMaxLimite = 5;
        //暴毙提醒值
        const float flBanWarnLimite = 0.66;
        //踢出原因
        const string szKickReason = "你不受欢迎";
        //封禁原因
        const string szBanReason = "你不受欢迎, 铁弱智";
        //根目录
        string szRootPath = "scripts/plugins/store/chatengine/";
        //储存名单位置
        const string szFilePath	= "SuckersList.txt";
        //敏感词库
        const string szCensorData = "Censor.dic";
        //禁言名单位置
        const string szMuteFilePath	= "MuterList.txt";
        //对话保存位置
        const string szChatLogFilePath = "/chatlog/";
        //玩家退出后是否向所有人在控制台展示其信息
        //0 不展示
        //1 展示SteamID
        //2 展示SteamID和IP
        const uint uiDissconnetShowInfo = 1;
        //玩家退出后是否清理其缓存
        const bool bCleanExit = false;
        //Version
        const string szVersion = "0.0.1";
    }

    namespace Log
    {
        //单独的屏蔽Log位置
        const string szLogPath = "ChatDetected.log";
        //Log标签 封禁玩家记录开头
        const string szLogBanHeader = "[Ban]";
        //Log标签 检测到不和谐玩家名称
        const string szLogName = "[Name]";
        //Log标签 检测到封禁词汇
        const string szLogDetected = "[KeyWord]";
        //Log格式
        const string szFormmat = "#%time%\t%tag%\t%id%\t%ip%\t%player%\t%content%\n";
    }

    namespace Player
    {
        //队伍标记
        const string szTeamTag = "(TEAM)";
        //死亡标记
        const string szDeadTag = "*DEAD*";
    }

    namespace Launguage
    {
        const string szGeneralStarting = "Chat插件已被重新加载，插件将暂时停用";
        const string szGeneralKicked = "你已经被服务器踢出";
        const string szGeneralBaned = "你已经被服务器永久封禁";
        const string szFailLoadPlugin = "封禁列表文件为空，为保证安全性，此文件将会在稍后被覆盖\n文件路径: {0}";
        const string szMuteFailLoadPlugin = "禁言列表文件为空，为保证安全性，此文件将会在稍后被覆盖\n文件路径: {0}";
        const string szLoadedPlugin = "已从封禁列表文件读取{0}个封禁用户";
        const string szMuteLoadedPlugin = "已从禁言列表文件读取{0}个封禁用户";
        const string szCommandForbidden = "你没有使用该命令的权限，至少需要[{0}]的权限";
        const string szCommandRegisted = "客户端命令：{0} 已经成功注册";
        const string szCommandEmpty = "客户端命令：{0} 为空！";
        const string szCommandCallbackEmpty = "客户端命令：{0} 可执行函数句柄为空！";
        const string szCommandExeced = "成功执行客户端命令：{0}";
        const string szCommandFailed = "无法执行客户端命令：{0}，请参考命令帮助信息";
        const string szCommandHelp = "所有可用命令如下：";
        const string szLeaveInfoHeader = "玩家: {0} 已经退出游戏，信息如下";
        const string szLeaveInfoIP = "IP: {0}";
        const string szLeaveInfoID = "SteamID: {0}";
        const string szChatCommand = "已执行 {0}, 无输出请按~前往控制台查看";
        const string szBanWarn = "已检测到 {0} 次敏感词汇，达到上限将永久封禁";
    }

    namespace KeyWord
    {
        const string szKeywordRegisted = "替换关键词: {0} 已经成功注册";
        const string szKeyWordHelp = "所有可用关键词如下：";
    }
}