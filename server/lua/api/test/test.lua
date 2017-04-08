math.randomseed (4) --把种子设置为100
ngx.say(math.random())         -->output  0.0012512588885159
ngx.say(math.random(100))      -->output  57
ngx.say(math.random(100, 360)) -->output  150
	local currentTime = os.time()
	math.randomseed (currentTime) 

	ngx.say(os.time())          
	ngx.say(math.random(100))       
  local randomNum =	 math.random(1, 10000)

  local usercode = tostring(currentTime)..tostring(randomNum)
	
  ngx.say(usercode)