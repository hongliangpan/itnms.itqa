<%@ page contentType="text/html;charset=UTF-8" language="java"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.google.common.io.Resources"%>
<%@ page import="its.dev.tools.ping.CmdCache"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Ping IP</title>
</head>
<body>
	<div align="center">
		<h2>Ping IP</h2>
	</div>
	<%
	    //http://127.0.0.1:8080/ping/pingip.jsp?ip=www.sina.com.cn&count=10&size=512&timeout=120
	    //http://127.0.0.1:8080/ping/pingip.jsp?ip=www.sina.com.cn&count=10&size=512&t=true&timeout=120
	    String ip = request.getParameter("ip");
	    CmdCache.remove(ip);
	    out.println(ip + "已经停止ping.");
	%>
</body>
</html>
