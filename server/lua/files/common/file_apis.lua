--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:file_apis.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  文件上传下载的接口封装文件,用户文件管理方案的接口定义
--]]




--[[
-- 上传文件基础功能文件，用于其他需要上传系统的调用，调用完成之后，将文件存储到系统中，大文件通过hadoop存储，
-- 小文件通过Haystack系统存储
-- 上传之后需要计算md5和sha1编码，同时生成唯一文件编号，写入数据库和redis系统中，写数据库和redis注意分布式存储
-- 一切处理完成之后，系统将文件唯一编号返回给系统，失败返回nil
-- 首先客户端将上传文件传送到本地址，根据客户端上传上来的文件的sha1 和 md5 判断是否存在该文件，如果存在则直接返回
-- 如果没有则存储到系统中，生成
-- example
   
--]]

local cjson     = require "cjson"
local resty_md5 = require "resty.md5"
local uuid      = require "resty.uuid"
local resty_sha1 = require "resty.sha1"

local upload    = require "resty.upload"
local str       = require "resty.string"
local db_help   = require "db.lua_db_help" 
local api_data  = require "common.api_data_help"
 
local file_help = require "files.common.file_help"




local _M = {}

--[[
-- 将 文件信息写入数据库，同时写入redis 该信息为基础的文件信息
-- example
    local 
    
-- @param file_code 文件唯一编码code
-- @param md5_code 文件md5码
-- @param sha1_code 文件sha1码
--]]
function _M.insert_new_file( file_code,sha1_code)
    --  首先从redis中查询一次是否存在该文件
    local redis_cli = file_db:new_redis();
    local resRedis = redis_cli:hgetall(sha1_code)
    if resRedis then
       
        return file_code;
    end
    
    --insert into mysql 
    -- body
    local mysql_cli = file_db:new_mysql();
    if not mysql_cli then

        return nil,1041;
    end

    local str = string.format("insert into t_file_records(file_code,sha1_code)values('%s','%s');", 
                            file_code,sha1_code) 
    
    local res, err, errcode, sqlstate = mysql_cli:query(str)
        if not res then
            ngx.log(ngx.ERR,"bad result: ".. err.. ": ".. errcode.. ": ".. sqlstate.. ".");
            if(errcode == 1062) then
                return file_code,errcode;
            end
            return nil,errcode;
        end



--  inser into redis
    if not redis_cli then
        ngx.log(ngx.ERR,zs_error_code.REDIS_CRE_CLI_ERROR);
    else
        res = redis_cli:hmset(sha1_code,"file_code",file_code)
        if not res then
           ngx.log(ngx.ERR,"redis_cli.hset error "..sha1_code);
        end
    end

    return file_code,errcode;
end

 
--[[
-- 将 查询是否存在指定文件sha1编码的文件存在
redis 中存储格式为hmap  key:sha1 
                      subkey: file_code value: filecodeimpl 
                      subkey: md5_code value: md5
-- example 
 
-- @param sha1_code 文件sha1码
--]]
function _M.find_file_by_sha1(sha1_code)

--  从redis中查询，如果不存在则在mysql中查询
    local redis_cli = file_db:new_redis();
    
    if not redis_cli then
        ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_CRE_CLI_ERROR);
    else
        local res = redis_cli:hgetall(sha1_code)
        if not res then
            ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_NO_DATA);
        else
            --ngx.log(ngx.ERR,zs_error_code.REDIS_CRE_CLI_ERROR);
            --ngx.say("redis 结果："..cjson.encode(res))
            return table.array2record(res);
        end
    end

    --从数据库中查询
    local mysql_cli = file_db:new_mysql();
    if not mysql_cli then
        return nil,1041;
    end
    local str = string.format("select * from t_file_records where sha1_code='%s'", sha1_code) 
     
    local res, err, errcode, sqlstate = mysql_cli:query(str)
    if not res then
        ngx.log(ngx.ERR,"bad result: ", err, ": ", errcode, ": ", sqlstate, ".");
        return nil,errcode; 
    end
  
    --  inser into redis
    if redis_cli then
        local fileRec = res[1]; 
        if fileRec then
        redis_cli:hmset(fileRec["sha1_code"],"file_code",fileRec["file_code"]);
        end
    end

    return res,errcode;
end

--[[
-- 搜索用户的存储文件,主要用于文件的查询 
-- example
    local srcSql = " select * from t_user_files "
    local db_help = require "db.lua_db_help"
    local param = db_help.new_param();
    param.user_code_fk="user_code_1"
    param.file_name="file"
    local start_index = args["start_index"] and args["start_index"] or 0;
    local offset = args["offset"] and args["offset"] or 20;
    local strsql = db_help.select_help(srcSql,param,"and")

-- @param srcSql sql 前半部分语句
-- @param param 用户需要组装的数据参数表,其中record 的元素信息必须为key=value的格式
                key为表的字段名
-- @param condition 搜索语句的条件,主要表现为字符串    
-- @param start_index,offset 用于分页查询 该参数可优化

--]]
function _M.find_user_files(srcSql,param,condition,start_index,offset)
     --从数据库中查询
    local mysql_cli = file_db:new_mysql();
    if not mysql_cli then
        return nil,1041;
    end
    
    local sql = db_help.select_help(srcSql,param,condition,start_index,offset)

    local res, err, errcode, sqlstate = mysql_cli:query(sql)
        if not res then
            ngx.log(ngx.ERR,"bad result: ", err, ": ", errcode, ": ", sqlstate, ".");
            return nil,errcode; 
        end
   
    return res,errcode;
end


--[[
    本地将解释一下 post 上传数据包括以下几种方式
    1, application/x-www-form-urlencoded
        这应该是最常见的 POST 提交数据的方式了。
        浏览器的原生 <form> 表单，如果不设置 enctype 属性，
        那么最终就会以 application/x-www-form-urlencoded 方式提交数据。
        请求类似于下面这样（无关的请求头在本文中都省略掉了）：
        BASHPOST http://www.example.com HTTP/1.1
Content-Type: application/x-www-form-urlencoded;charset=utf-8

title=test&sub%5B%5D=1&sub%5B%5D=2&sub%5B%5D=3
首先，Content-Type 被指定为 application/x-www-form-urlencoded；
其次，提交的数据按照 key1=val1&key2=val2 的方式进行编码，key 和 val 都进行了 URL 转码。
大部分服务端语言都对这种方式有很好的支持。例如 PHP 中，$_POST['title'] 
可以获取到 title 的值，$_POST['sub'] 可以得到 sub 数组。
很多时候，我们用 Ajax 提交数据时，也是使用这种方式。
例如 JQuery 和 QWrap 的 Ajax，Content-Type 默认值都是「application/x-www-form-urlencoded;charset=utf-8」。
    2,multipart/form-data
    这又是一个常见的 POST 数据提交的方式。我们使用表单上传文件时，必须让 <form> 表单的 enctyped 等于 multipart/form-data。
    直接来看一个请求示例：

    3,application/json 该模式主要直接封装成json进行上传 
]]

function get_filename(res)  
    local filename = ngx.re.match(res,'(.+)filename="(.+)"(.*)')  
    if filename then   
        return filename[2]  
    end  
end  
function get_uploadmsg(res)  
    local get_uploadmsg = ngx.re.match(res,'(.+)name="uploadmsg"(.*)')  
    if get_uploadmsg then   
        return get_uploadmsg[2]  
    end  
end  
function get_postmsg(res)  
    local get_uploadmsg = ngx.re.match(res,'(.+)name="(.*)')  
    if get_uploadmsg then   
        return get_uploadmsg[2]  
    end  
end  
--[[
-- _M.exsit_file_help( filesTable ) 该函数主要用于判断系统中是否存在指定的文件,
--  如果不存在指定文件,将结果加入返回的数据表中
-- example

-- @param filesTable 存储文件信息的数组,该数组中包含指定的字段sha1_code 字段 

--]]
function _M.file_exsit_help( filesTable )
    -- body
    if not filesTable then return nil end
    local len = table.getn(filesTable)
    local desTable = {} ;

    if len == 0 then return nil end
    local desIndex = 1;
    for i=1,len,1 do
        local fileInfo = filesTable[i]; 
        local res,err = _M.find_file_by_sha1(fileInfo.sha1_code)
        
        if  not table.isnull(res) then -- 没查找指定sha1码的文件  
            desTable[desIndex] = table.clone(fileInfo); 
            desIndex = desIndex + 1;
        end
    end
    return desTable;
end
--[[
-- _M.pre_uploading(_usercode) 文件上传主函数,客户端上传文件的保存与存储
--  由于可能存在多个文件上传，所以系统将上传之后的状态也会返回到客户端中
-- example
    local file_help = require "files.common.file_apis"
    -- 系统需要预处理一次,即一个用户只能上传一个或指定的多个文件
-- @param _usercode  用户唯一编号
--]]

function _M.pre_uploading( _usercode )
    local chunk_size = 500*1024 
    local form, err = upload:new(chunk_size)
    if not form then
        ngx.log(ngx.ERR, "failed to new upload: ", err)
        return api_data.new_failed();
    end  
     
    local upload_msg = nil;
    local upload_msg_body = nil;
    -- 用于更进一步的访问限制,减少系统被攻击的几率,在access接入的时候进行一次加密解密处理基本可以杜绝
    -- 如果有必要 可以再一次进行判断
    --local upload_msg_index = 0;
    while true do
        local typ, res, err = form:read()

        if not typ then
            ngx.log(ngx.ERR, "failed to read: ", err) 
            return  api_data.new_failed();
        end 
 
        if typ == "header" then
           upload_msg = get_uploadmsg(res[2]) 
           --upload_msg_index = upload_msg_index+1;
         elseif typ == "body"  then
            if upload_msg then
               upload_msg_body = res;   
               break;
            end
       
        elseif typ == "part_end" then
              -- do nothing
        elseif typ == "eof" then
            break

        else
            -- do nothing
        end
    end 

    -- 根据获取的msg信息处理需要上传的文件
    if not upload_msg_body then
        return api_data.new_failed();
    end
    local filesTable = cjson.decode(upload_msg_body);
   
    -- 生成唯一编码
    -- 随机生成uuid 通过md5进行唯一编码
    local md5 = resty_sha1:new()
    -- 生成唯一uuid
    local file_id = uuid.generate()
    -- 通过md5 编码一次
    md5:update(file_id)
    local md5_sum = md5:final()
    md5:reset()  

    local data = api_data.new_success();
    data.tokenex = str.to_hex(md5_sum);
    -- 写入redis
    local redis_cli = file_db:new_redis();
    
    if not redis_cli then
        ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_CRE_CLI_ERROR);
        return api_data.new_failed();
    else
        local file_token_ex = "files_token_ex_".._usercode;
        local res = redis_cli:set(file_token_ex,data.tokenex )
        if not res then
            ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_SET_ERROR);
            return api_data.new_failed();
        else
            -- 设置超时 5 秒 --
            local res = redis_cli:pexpire(file_token_ex,5000); 
            if not res then
                ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_PEXPIRE_ERROR);
                return api_data.new_failed();
            end
            
        end
    end  
    data.data = _M.file_exsit_help( filesTable ) 
    return data;
end 

--[[
-- _M.handle_uploading(token_ex) 文件上传主函数,客户端上传文件的保存与存储
--  由于可能存在多个文件上传，所以系统将上传之后的状态也会返回到客户端中
-- example
    local file_help = require "files.common.file_apis"
    -- 系统需要预处理一次,即一个用户只能上传一个或指定的多个文件
    -- 由于用户并发可能同时上传多个文件,系统第一期默认将所有的文件存储到本地
    -- 然后将文件通过sha1写入用户记录数据表和文件记录表
--]]
local dst_dir = "." 
function _M.handle_uploading()
    local chunk_size = 500*1024 
    local form, err = upload:new(chunk_size)
    if not form then
        ngx.log(ngx.ERR, "failed to new upload: ", err)
        return nil;
    end
    local sha1 = resty_sha1:new()  
    local uuid_name;
    local file = nil
    local post_key = nil;
    local extend_info = {};
    local files_info = {};
    while true do
        local typ, res, err = form:read() 
        if not typ then
            ngx.log(ngx.ERR, "failed to read: ", err) 
            return api_data.new_failed();
        end  
        if typ == "header" then
            local file_name = get_filename(res[2]) 
            if file_name then
                uuid_name = uuid.generate_time()..'.'..file_help.getExtension(file_name);
                
                file = io.open(dst_dir .. "/" .. uuid_name , "wb") 
                if not file then 
                    ngx.log(ngx.ERR, "failed to open file ", uuid_name) 
                    return api_data.new_failed();
                end  
            else
                post_key = get_postmsg(res[2])  
            end
        elseif typ == "body" then
            if file then
                file:write(res)
                sha1:update(res) 
            elseif post_key then
                extend_info[post_key] = res;        -- 可能存在bug!!!!!!!--------------
            end

        elseif typ == "part_end" then
            local sha1_sum = sha1:final()
            sha1:reset() 
            if file then
                file:close()
                file = nil
                files_info[uuid_name] = {sha1_code=str.to_hex(sha1_sum)};
            end  
           
        elseif typ == "eof" then
            break
        else
            -- do nothing
        end
    end

    local data = api_data.new_success();
    data.data = files_info;
    return data;
    
end 


return _M