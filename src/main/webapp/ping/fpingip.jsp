<%@ page contentType="text/html;charset=UTF-8" language="java"	pageEncoding="UTF-8"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.google.common.io.Resources"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="its.dev.tools.ping.CmdCache"%>
<%@ page import="its.dev.tools.ping.PingTask"%>

<%@ page import="org.slf4j.Logger"%>
<%@ page import="org.slf4j.LoggerFactory"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> 
<html> 
<head> 
<title>Ping IP</title>
<style type="text/css">
    body {
        background: #000000;
        font-size: 12px;
        font-family: Arial;
    }
</style>
</head>
<body>
<%
    Logger logger = LoggerFactory.getLogger(CmdCache.class);
    try {
        Class.forName("its.dev.tools.ping.CmdCache");
    } catch (ClassNotFoundException e) {
        logger.error(e.getMessage(), e);
    }
    //http://127.0.0.1:8080/ping/pingip.jsp?ip=www.sina.com.cn&count=10&size=512&timeout=120
    //http://127.0.0.1:8080/ping/pingip.jsp?ip=www.sina.com.cn&count=10&size=512&t=true&timeout=120
    final String ip = request.getParameter("ip");
    if (!CmdCache.isPing(ip)) {
        String count = request.getParameter("count");
        String size = request.getParameter("size");
        String timeout = request.getParameter("timeout");//超时单位秒
        String t = request.getParameter("t");
        boolean pingAlways = false;
        if ("true".equalsIgnoreCase(t)) {
            pingAlways = true;
            //或者做一下转换，一直ping 改为 ping count 很大，超时时间24小时等
            //count = "10000";
            //timeout = 24 * 60 * 60 + "";
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
            String fpingProc = "fping.exe";
            String osName = System.getProperty("os.name");
            if (osName.indexOf("Windows") >= 0) {
                fpingProc = "fping.exe";
            } else {
                //TODO linux like
                fpingProc = "fping";
            }
            String fping = Resources.getResource(fpingProc).getFile();
            //System.out.println(fping);
            // -t
            String commonParam = " -s " + size + " -T -j";
            String cmdParams = ip + " -n " + count + commonParam;
            if (pingAlways) {
                cmdParams = ip + " -c " + commonParam + " -t 1500";
            }
            String cmdMemo =
                    "参数: ip="
                            + cmdParams.replaceAll(" -n ", ", 次数=")
                                    .replaceAll(" -s ", ", 包大小[字节]=")
                                    .replaceAll(" -c ", ", 持续ping")
                                    .replaceAll(" -T", ", 显示时间")
                                    .replaceAll(" -j", ", 显示抖动时延")
                                    .replaceAll(" -t", ", 发包间隔[毫秒]=");

            cmdMemo += ", 超时时间[秒]=" + timeout + ".";

            String cmd = fping + " " + cmdParams;
            final Process process = runtime.exec(cmd);

            SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            final String key =
                    cmd + "	" + process.hashCode() + " " + format.format(new Date())
                            + " timeout=" + timeout;

            out.println("<font style=\"color: #ffffff;\">");
            out.println("fping " + cmdParams + "<br>");
            out.println(cmdMemo);
            out.println("</font>");

            PingTask task = new PingTask();
            task.setIp(ip);
            task.setProcess(process);
            task.setRuntime(runtime);
            task.setStartTime(new Date());
            task.setConfig(key);
            CmdCache.put(ip, task);

            timer.schedule(new TimerTask() {
                public void run() {
                    CmdCache.remove(ip);
                    process.destroy();
                    //System.out.println("destroy timeout " + key);
                }
            }, Integer.parseInt(timeout) * 1000);
            // windows默认是GBK，Linux是UTF-8  
            br = new BufferedReader(new InputStreamReader(process.getInputStream(), "GBK"));
            out.println("<pre>");
            String line = null;
            out.println("<font style='color: #ffffff;padding:0px; margin:0px;'>");
            while ((line = br.readLine()) != null) {
                if ("".equals(line.trim()) || line.startsWith("Pinging")) {
                    continue;
                }
                if (line.startsWith("Fast pinger version") || line.startsWith("(c) Wouter")) {
                    continue;
                }
                
                line = line.replaceAll("Could not resolve the host name", "不能解析主机名或IP地址:");
                line = line.replaceAll("request timed out", "请求超时.");


                line = line.replaceAll("Ping statistics for", "<br>Ping统计信息,IP=");
                line =
                        line.replaceAll("Packets: Sent", "数据包,已发送")
                                .replaceAll("Received", "已接收").replaceAll("Lost", "丢失")
                                .replaceAll("loss", "丢失");
                line =
                        line.replaceAll("Approximate round trip times in milli-seconds:",
                                "往返行程的估计时间【以毫秒为单位,RTT(Round-Trip Time)往返时延】:");
                line =
                        line.replaceAll("Minimum", "最短RTT").replaceAll("Maximum", "最长RTT")
                                .replaceAll("Average", "平均RTT");

                line = line.replaceAll("from " + ip, "来自" + ip);
                line =
                        line.replaceAll("bytes", "字节").replaceAll("time", "时间")
                                .replaceAll("jitter", "抖动").replaceAll("Reply", "回复")
                                .replaceAll("from", "来自");

                line = line.replaceAll(" ms", "ms");
                out.println(line);
                out.flush();
            }
            out.println("</font>");
            out.println("</pre>");
            CmdCache.remove(ip);
            process.destroy();
            //System.out.println("destroy  " + key);
        } catch (IOException e) {
            logger.error(e.getMessage(), e);
            out.println(e);
            //runtime.exit(1);
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
    } else {
        out.println("<font style='color: #ffffff;padding:0px; margin:0px;'>");
        out.println(ip + "已经在ping...");
        out.println("</font>");
    }
%>
</body> 
</html> 