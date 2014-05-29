
# fping test
##测试方法
http://127.0.0.1:8090/itqa/ping/fpingip.jsp?ip=www.baidu.com&count=10&size=512&timeout=120
http://127.0.0.1:8090/itqa/ping/fpingip.jsp?ip=127.0.0.1&count=10&size=512&timeout=120

http://127.0.0.1:8090/itqa/ping/fpingip.jsp?ip=www.baidu.com&count=100&size=512&timeout=120
http://127.0.0.1:8090/itqa/ping/fpingip.jsp?ip=127.0.0.1&count=100&size=512&timeout=120

http://127.0.0.1:8090/itqa/ping/fpingip.jsp?ip=172.17.189.71&count=100&size=512&timeout=120
##一直ping
http://127.0.0.1:8090/itqa/ping/fpingip.jsp?ip=172.17.189.71&t=true&size=512&timeout=12000

关闭ping cmd窗口
http://127.0.0.1:8090/itqa/ping/closeping.jsp?ip=www.baidu.com
http://127.0.0.1:8090/itqa/ping/closeping.jsp?ip=127.0.0.1


发布到adapter
http://127.0.0.1/adapter/ping/fpingip.jsp?ip=127.0.0.1&count=10&size=512&timeout=120


http://127.0.0.1:8081/adapter/ping/fpingip.jsp?ip=127.0.0.1&count=10&size=512&timeout=12