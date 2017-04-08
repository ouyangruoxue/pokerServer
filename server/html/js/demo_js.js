 // 添加这个函数，可以在js页面中引入其他js文件
 function include(path){ 
    var a=document.createElement("script");
    a.type = "text/javascript"; 
    a.src=path; 
    var head=document.getElementsByTagName("head")[0];
    head.appendChild(a);
    }

// 以下为两种引用方式例子
// include("js/json2.js");
// include("http://hcl0208.cnblogs.com/test.js");   
 
 include("/js/json2.js");		 // 引入json2  js文件
 include("/js/verify.js");		 // 引入验证js文件
 
	var glob=1
	// 1 means nomoral login，
	// 2 means phone login(nomoral), 
	// 3 means wechar login, 
	// 4 means qq login, 
	// 5 means sina login
	
	
	// 如果当前文件相对于index.html是同级文件，那么level传0，如果当前文件是index.html文件的下一级文件，比如book文件夹中的，或者js文件夹中的，level传1，最终得到的路径，是index.html的上级目录
	function getRootPath(level){
		level+=1
		var	opath
		var sign_index
		do{
			 opath=location.href //获取文件当前路径
			 sign_index=opath.lastIndexOf("/")   //获取最后一个/的index值
			 opath=opath.substr(0,sign_index)  //截取从第一个到最后一个/之间的字符串
			level--;
		} while(level)
			return opath;
		
	}


	// 打开登录框
	function shw_log(){
		dsp_reg()
		document.getElementsByClassName("loginRegDialog")[0].style.display=""
	}
	
	// 打开注册框
	function shw_reg(){
		dsp_log()
		document.getElementsByClassName("loginRegDialog")[1].style.display=""
	}
	
	// 关闭登录框
	function dsp_log(){
	// obj.parentNode.parentNode.style.display="none" 
		document.getElementsByClassName("loginRegDialog")[0].style.display="none"
	}
	
	//关闭注册框
	function dsp_reg(){
		document.getElementsByClassName("loginRegDialog")[1].style.display="none"
	}
	
	// <!-- 选择登录方式 选中的登录方式出现，没有选中的隐藏 -->
	function selway(obj){
	var cssName=obj.className
		if("loginWay"==cssName){ 
			// <!-- 其他方式登录隐藏 手机号码登录出现 -->
			
			document.getElementsByClassName("loginWay")[0].style.display="none"
			document.getElementsByClassName("loginWay2")[0].style.display=""
			document.getElementsByClassName("loginAccountWay")[0].style.display="none"
			document.getElementsByClassName("loginMobilePhoneWay")[0].style.display=""
			glob=2
			
		}else if("loginWay2"==cssName){
			// <!-- 其他方式登录隐藏，普通登录出现 -->
			
			document.getElementsByClassName("loginWay")[0].style.display=""
			document.getElementsByClassName("loginWay2")[0].style.display="none"
			document.getElementsByClassName("loginAccountWay")[0].style.display=""
			document.getElementsByClassName("loginMobilePhoneWay")[0].style.display="none"
			glob=1
		}//其他的登录方式因为登录界面没做，所以这里待定
	}
	

	
	
	// 手机登录 点击获取验证码
	function getPIN(){
		alert("sorry ! the phone PIN server not allow")
	}
	
	
	// 点击登录按钮
	function login(obj){
		var usn;
		var psw;
		var lgtype;

		if(glob==1){
			usn=document.getElementsByClassName("loginAccountWay")[0].getElementsByClassName("loginInputBox")[0].getElementsByTagName("input")[0].value
			psw=document.getElementsByClassName("loginAccountWay")[0].getElementsByClassName("loginInputBox")[1].getElementsByTagName("input")[0].value
			lgtype="normal"
		}else if(glob==2){
			usn=document.getElementsByClassName("loginMobilePhoneWay")[0].getElementsByClassName("loginInputBox")[0].getElementsByTagName("input")[0].value
			psw=document.getElementsByClassName("loginMobilePhoneWay")[0].getElementsByClassName("loginInputBox")[1].getElementsByTagName("input")[0].value
			lgtype="normal"
		}else if (glob==3){
			// 这里是微信或者其他登录
			
		}
		log_by_uap(lgtype,usn,psw);
	}
	
	// 点击注册按钮
	function reg_but(){
		var reg_name=document.getElementsByClassName("regStepTwo")[0].getElementsByClassName("regInputBox")[0].getElementsByTagName("input")[0].value
		var reg_psw=document.getElementsByClassName("regStepTwo")[0].getElementsByClassName("regInputBox")[0].getElementsByTagName("input")[0].value
		if(""!=reg_name){
			var regtype="nomal" //普通的注册方式(uap)
			reg_by_uap(regtype,reg_name,reg_psw)
		}else{
			alert("请输入正确的用户名/密码")
		}
		
	}
	
	// 注册的ajax
	function reg_by_uap(regtype,usn,psw){
		 $.ajax({ 
			type:"get", 
			url:"http://localhost/api/user/register", 
			data:{
				"regtype":regtype,
				"username":usn,
				"password":psw,
				}, 
			cache:false,
			success:function(data,status){ 
			alert(data)
				var dateJson = JSON.parse(data)	 
				if(200==dateJson.status){
					alert("注册成功！")
					shw_log()
				}else{
					alert("注册失败！")
				}
			}
		 }) 
	}
	
	
	// 登录的ajax
	function log_by_uap(lgtype,usn,psw){
		 $.ajax({ 
			type:"get", 
			url:"http://localhost/api/user/login", 
			data:{
				"logintype":lgtype,
				"username":usn,
				"password":psw,
				}, 
			cache:false,
			success:function(data,status){ 
				var dateJson = JSON.parse(data)	 
				if(200==dateJson.code){
					suc_log() 
				}else{
					alert("登录失败！")
				}
			}
		 }) 
	}
	
	
	// 新建书本时的操作
	function new_type_book(obj){
		var booktype=obj.className
		document.getElementsByClassName("newBookDialog")[0].style.display="none"
		if ("newBookType newBookTypeOne"==booktype){
			 //跳转到QQ 绑定界面
			// document.getElementsByClassName("newBookDialog newBookDialogQQ")[0].style.display=""
			
			window.location.href="/book/new_qq.html"
		}else if ("newBookType newBookTypeTwo"==booktype){
			// 跳转到微信 绑定界面
			// document.getElementsByClassName("newBookDialog newBookDialogWeChat")[0].style.display=""
			window.location.href=getRootPath(1)+"/book/new_wechat.html"
		}else if ("newBookType newBookTypeThree"==booktype){
			// 跳转到微博 绑定界面
			// document.getElementsByClassName("newBookDialog newBookDialogWebo")[0].style.display=""
			window.location.href=getRootPath(1)+"/book/new_sina.html"
		}else if ("newBookType newBookTypeFour"==booktype){
			// 自定义书本
		}
	}
	
	// 关闭新建书本界面  绑定界面   个人认为对这里进行关闭操作时，应该退回到之前一步
	function clo_type_book(obj){
		// obj.parentNode.style.display="none"
		window.history.go(-1); 
	}
	
	// 对输入框进行检查判断
	function check_input(obj){
		var plac=obj.getAttribute("placeholder")
		var c_val=trim(obj.value)
		if("手机号/邮箱/用户名"==plac||"密码"==plac){
			if(isalphanumber(c_val)|| isemail(c_val)||ismobil(c_val)){
				// 验证通过
			}else{
				alert("请输入正确的用户名/密码！")
			}
			
		}else if("验证码"==plac){
			if(isverify(plac)){
				//验证通过
			}else{
				alert("验证码不正确")
			}
			
		}else if ("输入你的QQ账号"==plac){
			if(isqq(plac)){
				//验证通过
			}else{
				alert("请输入正确的QQ号")
			}
		}else if ("输入您的微信号"==plac){
			if(iswechat(plac)){
				//验证通过
			}else{
				alert("请输入正确的微信号")
			}
			
		}else if ("输入您的微博个人主页网址"==plac){
			// 暂时放一放
			
		}
	}