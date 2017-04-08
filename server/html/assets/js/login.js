 // 添加这个函数，可以在js页面中引入其他js文件
 function include(path){ 
    var a=document.createElement("script");
    a.type = "text/javascript"; 
    a.src=path; 
    var head=document.getElementsByTagName("head")[0];
    head.appendChild(a);
    }

 
 include("/assets/js/json2.js");		 // 引入json2  js文件
 include("/assets/js/verify.js");		 // 引入验证js文件
 include("http://cdn.bootcss.com/blueimp-md5/1.1.0/js/md5.js")
 
	
	// 如果当前文件相对于index.html是同级文件，那么level传0，如果当前文件是index.html文件的下一级文件，比如book文件夹中的，或者js文件夹中的，level传1，最终得到的路径，是index.html的上级目录
	function getRootPath(level){
		level+=1
		var	opath=location.href //获取文件当前路径
		var sign_index
		
		do{
			 sign_index=opath.lastIndexOf("/")   //获取最后一个/的index值
			 opath=opath.substr(0,sign_index)  //截取从第一个到最后一个/之间的字符串
			level--;
		} while(level)
			return opath;
		
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
		
		//调用登陆方法
			var lock_paw=md5(psw)
			console.log(lock_paw)
			log_by_uap(lgtype,usn,lock_paw);
		
	}
	
	// 点击注册按钮
	function reg_but(){
		var reg_name=document.getElementsByClassName("regStepTwo")[0].getElementsByClassName("regInputBox")[0].getElementsByTagName("input")[0].value
		var reg_psw=document.getElementsByClassName("regStepTwo")[0].getElementsByClassName("regInputBox")[0].getElementsByTagName("input")[0].value
		if(""!=reg_name){
			var regtype="nomal" //普通的注册方式(uap)
			var lock_paw=md5(reg_psw)
			console.log(lock_paw)
			reg_by_uap(regtype,reg_name,lock_paw)
		}else{
			console.log("请输入正确的用户名/密码")
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
					window.location.href = '你的跳转的目标地址';
				}else{
					alert("登录失败！")
				}
			}
		 }) 
	}
	
	// 对输入框进行检查判断
	function check_input(obj){
		var plac=obj.getAttribute("placeholder")
		var c_val=trim(obj.value)
		if("手机号/邮箱/用户名"==plac||"密码"==plac){
			if(isalphanumber(c_val)|| isemail(c_val)||ismobil(c_val)){
				
			}else{
				console.log("请输入正确的用户名/密码！")
			}
			
		}else if("验证码"==plac){
			if(isverify(plac)){
				
			}else{
				console.log("验证码不正确")
			}
			
		}
	}