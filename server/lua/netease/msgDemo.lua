--消息格式示例:
--1.文本消息

{
    "from":"test1",
    "ope":0,
    "to":"test2",
    "type":0,--文本消息类型
    "body":{
        "msg":"哈哈哈"--消息内容
    }
}
--2 图片消息

{
    "from":"test1",
    "ope":0,
    "to":"test2",
    "type":1    --图片类型消息
    "body":{
        "name":"图片发送于2015-05-07 13:59",   --图片name
        "md5":"9894907e4ad9de4678091277509361f7",    --md5
        "url":"http:--nimtest.nos.netease.com/cbc500e8-e19c-4b0f-834b-c32d4dc1075e",    --生成的url
                "ext":"jpg",    --图片后缀
        "w":6814,    --宽
        "h":2332,    --高
        "size":388245    --图片大小
    }
}
--3 语音消息

{
    "from":"test1",
    "ope":0,
    "to":"test2",
    "type":2    --语音类型消息
    "body":{
        "dur":4551,        --语音持续时长ms
        "md5":"87b94a090dec5c58f242b7132a530a01",    --md5
        "url":"http:--nimtest.nos.netease.com/a2583322-413d-4653-9a70-9cabdfc7f5f9",    --生成的url
        "ext":"aac",        --语音消息格式，只能是aac格式
        "size":16420        --语音文件大小
    }
}
--4 视频消息

{
    "from":"test1",
    "ope":0,
    "to":"test2",
    "type":3    --视频类型消息
    "body":{
        "dur":8003,        --视频持续时长ms
        "md5":"da2cef3e5663ee9c3547ef5d127f7e3e",    --md5
        "url":"http:--nimtest.nos.netease.com/21f34447-e9ac-4871-91ad-d9f03af20412",    --生成的url
        "w":360,    --宽
        "h":480,    --高
        "ext":"mp4",    --视频格式
        "size":16420    --视频文件大小
    }
}
--5 发送地理位置消息

{
    "from":"test1",
    "ope":0,
    "to":"test2",
    "type":4    --地理位置类型消息
    "body":{
        "title":"中国 浙江省 杭州市 网商路 599号",    --地理位置title
        "lng":120.1908686708565,        -- 经度
        "lat":30.18704515647036            -- 纬度
    }
}
--6 发送文件消息

{
    "from":"test1",
    "ope":0,
    "to":"test2",
    "type":6    --文件消息
    "body":{
        "name":"BlizzardReg.ttf",    --文件名
        "md5":"79d62a35fa3d34c367b20c66afc2a500", --文件MD5
        "url":"http:--nimtest.nos.netease.com/08c9859d-183f-4daa-9904-d6cacb51c95b", --文件URL
        "ext":"ttf",    --文件后缀类型
        "size":91680    --大小
    }
}
--7 发送第三方自定义消息

{
    "from":"test1",
    "ope":0,
    "to":"test2",
    "type":100    --第三方自定义消息
    --第三方定义的body体，json串
    "body":{
        "myKey":myValue    
    }
}