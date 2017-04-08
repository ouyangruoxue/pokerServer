
/**
sha1 编码
**/
function sha1(data){ 
  var i,j,t;
  var l=((data.length+8)>>>6<<4)+16,s=new Uint8Array(l<<2);
  s.set(new Uint8Array(data.buffer)),s=new Uint32Array(s.buffer);
  for(t=new DataView(s.buffer),i=0;i<l;i++)s[i]=t.getUint32(i<<2);
  s[data.length>>2]|=0x80<<(24-(data.length&3)*8);
  s[l-1]=data.length<<3;
  var w=[],f=[
    function(){return m[1]&m[2]|~m[1]&m[3];},
    function(){return m[1]^m[2]^m[3];},
    function(){return m[1]&m[2]|m[1]&m[3]|m[2]&m[3];},
    function(){return m[1]^m[2]^m[3];}
  ],rol=function(n,c){return n<<c|n>>>(32-c);},
  k=[1518500249,1859775393,-1894007588,-899497514],
  m=[1732584193,-271733879,null,null,-1009589776];
  m[2]=~m[0],m[3]=~m[1];
  for(i=0;i<s.length;i+=16){
    var o=m.slice(0);
    for(j=0;j<80;j++)
      w[j]=j<16?s[i+j]:rol(w[j-3]^w[j-8]^w[j-14]^w[j-16],1),
      t=rol(m[0],5)+f[j/20|0]()+m[4]+w[j]+k[j/20|0]|0,
      m[1]=rol(m[1],30),m.pop(),m.unshift(t);
    for(j=0;j<5;j++)m[j]=m[j]+o[j]|0;
  };
  t=new DataView(new Uint32Array(m).buffer);
  for(var i=0;i<5;i++)m[i]=t.getUint32(i<<2);
  return new Uint8Array(new Uint32Array(m).buffer);
};