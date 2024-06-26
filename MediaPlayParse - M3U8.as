/*
    资源站视频
*/

// void OnInitialize()
// void OnFinalize()
// string GetTitle() 									-> get title for UI
// string GetVersion									-> get version for manage
// string GetDesc()										-> get detail information
// string GetLoginTitle()								-> get title for login dialog
// string GetLoginDesc()								-> get desc for login dialog
// string GetUserText()									-> get user text for login dialog
// string GetPasswordText()								-> get password text for login dialog
// string ServerCheck(string User, string Pass) 		-> server check
// string ServerLogin(string User, string Pass) 		-> login
// void ServerLogout() 									-> logout
//------------------------------------------------------------------------------------------------
// bool PlayitemCheck(const string &in)					                                            -> check playitem
// string PlayitemParse(const string &in path,dictionary &MetaData, array<dictionary> &QualityList)	-> parse playitem
// bool PlaylistCheck(const string &in)																-> check playlist
// array<dictionary> PlaylistParse(const string &in)												-> parse playlist

string GetTitle()
{
    return "M3U8";
}

string GetVersion()
{
    return "1";
}

string GetDesc()
{
    return "M3U8";
}

string USERAGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36";
string HOMEURL;
int RI, PG;
bool isOnly;
JsonReader JSON;
array<string> URLLIST={
    "https://ikunzyapi.com/api.php/provide/vod",
    "https://www.feisuzyapi.com/api.php/provide/vod/",
    "https://m3u8.tiankongapi.com/api.php/provide/vod/from/tkm3u8",
    "https://api.ukuapi.com/api.php/provide/vod/",
    "https://api.1080zyku.com/inc/apijson.php",
    };

void getHomeURL(string name)
{
    HOMEURL = URLLIST[RI] + "?ac=list&PG="+PG+"&wd=" + HostUrlEncode(name);
}

JsonValue getPlayList()
{
    JsonValue ret;
    string tempstr = HostUrlGetString(HOMEURL, USERAGENT, "", "", false);
    JSON.parse(tempstr, ret);
    return ret["list"];
}

JsonValue getItemdetail(string ids)
{
    JsonValue ret;
    string detailurl = URLLIST[RI] + "?ac=detail&ids=" + ids;
    HostPrintUTF8(detailurl);
    string tempstr = HostUrlGetString(detailurl, USERAGENT, "", "", false);
    JSON.parse(tempstr, ret);
    return ret["list"];
}

array<string> handelUrlStr(string url)
{
    array<string> ret;
    if(url.find('#')>0)
    {
        url.replace("#","$");
    }
    else{
        url.replace("$$$","$");
    }
    ret = url.split("$");
    //HostPrintUTF8(url);
    return ret;
}

bool PlaylistCheck(const string & in path)
{
    if(path.find("panvideo") == 0  or  path.find("://") >= 0 or path.find(":\\") >= 0)
    {
        return false;
    }

    path.replace("?WithCaption", "");
    array < string > temp = path.split("#");
    if(temp.size() < 1 or temp.size() >= 3)
    {
        return false;
    }
    isOnly = false;
    if(temp[0].find("￥") == 0 || temp[0].find("$") == 0) {
        isOnly = true;
    }
    RI = 0;
    PG = 1;
    if(temp.size() > 1){
        if(parseInt(temp[1])<100){
            RI = parseInt(temp[1])-1;
        }
        else{
            RI = parseInt(temp[1])/100-1;
            PG = parseInt(temp[1])%100;
        }
    }
    string name = temp[0].TrimLeft("$￥");
    getHomeURL(name);
    return true;
}

array < dictionary > PlaylistParse(const string & in path)
{
    //HostOpenConsole();
    path.replace("?WithCaption", "");
    array < dictionary > ret;
    string tempstr,ids,orign = path.split("#")[0];
    JsonValue Itemlist;
    JsonValue showList;

    // HostPrintUTF8(HOMEURL);
    Itemlist = getPlayList();
    
    for (int i = 0; i < Itemlist.size(); i++) 
    {
        ids = ids + Itemlist[i]["vod_id"].asString() + ",";
    }
    showList = getItemdetail(ids);
    for (int i = 0; i < showList.size(); i++) 
    {
        string showName = showList[i]["vod_name"].asString();
        if(isOnly && ("$"+showName != orign && "￥"+showName != orign))
        {
            // HostPrintUTF8(showName);
            continue;
        }
        array <string> showurl = handelUrlStr(showList[i]["vod_play_url"].asString());
        dictionary item;
        for (int j = 0; j < showurl.size(); j++)
        {
            if(showurl[j]=="")
            {
                continue;
            }
            else if(showurl[j].find("http") < 0)
            {
                item["title"] = "【资源"+(RI+1)+"】"+showName +" "+ showurl[j];
            }
            else if(showurl[j].find("m3u8") > 0)
            {
                item["url"] = showurl[j];
                ret.insertLast(item);   
            }
        }
    }
    return ret;
}
