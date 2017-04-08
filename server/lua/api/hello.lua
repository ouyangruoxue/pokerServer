local cjson=require "cjson"
require "helloZS"

ngx.say(api_common_version)


--
local cache=ngx.shared.ngx_cache
cache:set('hah',"zhangliutong",10000)
ngx.say(cache:get('hah'))

--ngx.req.read_body()
--local args=ngx.req.get_post_args()
--
--if not args or not args.info then 
--	ngx.exit(ngx.HTTP_BAD_REQUEST)
--	end

local test={'a1','a2'}
test[1000]='a100'
cjson.encode_sparse_array(true)
ngx.say(cjson.encode(test))

mytable={}

if  not mytable then 
else

	mytable={}
	mytable.a=100;
	ngx.say('nill');
end

mytable.a= mytable.a+100;
ngx.say(mytable.a)

