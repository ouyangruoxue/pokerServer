--历史消息查询返回的消息格式说明
--1.普通文本消息

{
    "from":”test1”,
    "msgid":792478,
    "sendtime":1430967883307,
    "type":0,--文本消息类型
    "body":{
        "msg":"哈哈哈"--消息内容
     }
}
--2.图片消息

{
    "from":”test1”,
    "msgid":792502,
    "sendtime":1430978396680,   --发送时间ms
    "type":1    --图片类型消息
    "body":{
        "name":"图片发送于2015-05-07 13:59",         --图片name
        "md5":"9894907e4ad9de4678091277509361f7",   --md5
        "url":"http:--nimtest.nos.netease.com/cbc500e8-e19c-4b0f-834b-c32d4dc1075e",    --生成的url
        "ext":"jpg",        --图片后缀
        "w":6814,       --宽
        "h":2332,       --高
        "size":388245       --图片大小
    }
}
--3.语音消息

{
    "from":”test1”,
    "msgid":792479,
    "sendtime":1430967899646,   --发送时间ms
    "type":2    --语音类型消息
    "body":{
        "dur":4551,     --语音持续时长ms
        "md5":"87b94a090dec5c58f242b7132a530a01",   --md5
        "url":"http:--nimtest.nos.netease.com/a2583322-413d-4653-9a70-9cabdfc7f5f9",    --生成的url
        "ext":"aac",        --语音消息格式，只能是aac格式
        "size":16420        --语音文件大小
    }
}
4.视频消息

{
    "from":”test1”,
    "msgid":792505,
    "sendtime":1430978424249,   --发送时间ms
    "type":3    --视频类型消息
    "body":{
        "dur":8003,     --视频持续时长ms
        "md5":"da2cef3e5663ee9c3547ef5d127f7e3e",   --md5
        "url":"http:--nimtest.nos.netease.com/21f34447-e9ac-4871-91ad-d9f03af20412",    --生成的url
        "w":360,    --宽
        "h":480,    --高
        "ext":"mp4",    --视频格式
        "size":16420    --视频文件大小
    }
}
5.地理位置消息

{
    "from":”test1”,
    "msgid":792501,
    "sendtime":1430978381896,   --发送时间ms
    "type":4    --地理位置类型消息
    "body":{
        "title":"中国 浙江省 杭州市 网商路 599号",  --地理位置title
        "lng":120.1908686708565,        -- 经度
        "lat":30.18704515647036         -- 纬度
    }
}
6.文件消息

{
    "msgid":7925061,
    "sendtime":1430978435894,   --发送时间ms
    "type":6    --文件消息
    "body":{
       "name":"BlizzardReg.ttf",   --文件名
       "md5":"79d62a35fa3d34c367b20c66afc2a500", --文件MD5
       "url":"http:--nimtest.nos.netease.com/08c9859d-183f-4daa-9904-d6cacb51c95b", --文件URL
       "ext":"ttf",    --文件后缀类型
       "size":91680    --大小
    }
}
7.第三方自定义消息

{
    "msgid":792506,
    "sendtime":1430978435894,   --发送时间ms
    "type":100, --第三方自定义消息
    "body":{     --自定义的内容，需要符合json格式
        …
    }
}
8.群内系统通知

{
    "msgid ":278703112201,
    "from":"t4",                --通知发起者
    "sendtime":1430978435894,   --发送时间ms
    "type":5    --群notifycation通知
    "body":{
       "tid":4153,     --群id
       "tname":"key1", --群名称 （某些操作会有）
       "ope":1,            --notify通知类型 （0:群拉人，1:群踢人，2:退出群，3:群信息更新，4:群解散，5:申请加入群成功，6:退出并移交群主，7:增加管理员，8:删除管理员，9:接受邀请进群）
       "accids":["t2"],    --被操作的对象 （群成员操作时才有）
       "intro":"群介绍",  --（ope=3时群信息修改项）
       "announcement":"群公告", （ope=3时群信息修改项）
       "joinmode":1,       --加入群的模式0不需要认证，1需要认证 ,（ope=3时群信息修改项）
       "config":"第三方服务器配制修改项",（ope=3时群信息修改项）
       "updatetime":1432804852021 --通知后台更新时间 （群操作时有）
    }
}