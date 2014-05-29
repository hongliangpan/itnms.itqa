<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"	pageEncoding="UTF-8"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 
<html> 
<head> 
<title>Ping IP</title> 
</head>
<body>
<%
    //http://127.0.0.1:8090/bmc/ping/pingip.jsp?ip=www.sina.com.cn&count=10&size=512&timeout=120
    //http://127.0.0.1:8080/ping/pingip.jsp?ip=www.sina.com.cn&count=10&size=512&t=true&timeout=120
    String ip = request.getParameter("ip");
    String count = request.getParameter("count");
    String size = request.getParameter("size");
    String timeout = request.getParameter("timeout");//超时单位秒
    String t = request.getParameter("t");
    boolean pingAlways = false;
    if ("true".equalsIgnoreCase(t)) {
        //pingAlways = true;
        //或者做一下转换，一直ping 改为 ping count 很大，超时时间24小时等
        count="10000";
        timeout=10*60*60+"";
    }
    if (null == count || count.trim().equals("")) {
        count = "10";
    }
    if (null == size || size.trim().equals("")) {
        size = "256";
    }
    if (null == timeout || timeout.trim().equals("")) {
        timeout = "60";
    }

    Runtime runtime = Runtime.getRuntime();
    BufferedReader br = null;
    Timer timer = new Timer();
    try {
        // -t
        String cmd = "ping " + ip + " -n " + count + " -l " + size;
        if (pingAlways) {
            cmd = "ping " + ip + " -t " + " -l " + size;
        } 
        
        final Process process = runtime.exec(cmd);
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        final String key=cmd+"	"+process.hashCode()+" "+format.format(new  Date())+" timeout="+timeout;
        out.println("<font style=\"color: #ffffff;\">");
        out.println(cmd);
        out.println("</font>");
        timer.schedule(new TimerTask() {
            public void run() {
                process.destroy();
                System.out.println("destroy timeout "+key);
            }
        }, Integer.parseInt(timeout) * 1000);
        // windows默认是GBK，Linux是UTF-8  
        br = new BufferedReader(new InputStreamReader(process.getInputStream(), "GBK"));
        out.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">");
        out.println("<HTML>");
        out.println("  <HEAD><TITLE>Ping " + ip + "</TITLE>");
        // out.println("  <meta http-equiv=\"Expires\" CONTENT=\"-1\">");
        // out.println("  <meta http-equiv=\"Cache-Control\" CONTENT=\"no-cache\"> ");
        // out.println("  <meta http-equiv=\"Pragma\" CONTENT=\"no-cache\">");
        out.println("  <style>");
        out.println(" BODY { MARGIN: 0px;background-color: #000000;FONT-SIZE: 12px;font-family: \"Arial\", \"Helvetica\", \"sans-serif\";");
        out.println(" }");
        out.println("  </style>");
        out.println("  </HEAD>");
        out.println("  <BODY style=\"background-color:black\">");
        out.println("<pre>");
        String line = null;
        out.println("<font style=\"color: #ffffff;\">");
        while ((line = br.readLine()) != null) {
            out.println(line);
            out.flush();
        }
        out.println("</font>");
        out.println("</pre>");
        process.destroy();
        System.out.println("destroy  "+key);
    } catch (IOException e) {
        e.printStackTrace();
        out.println(e);
        runtime.exit(1);
    } finally {
        if (br != null) {
            try {
                br.close();
            } catch (IOException e) {
                // e.printStackTrace();
            }
            br = null;
        }
        timer.cancel();
    }
%>
</body> 
</html> 