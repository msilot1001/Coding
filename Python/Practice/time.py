import time

sec = time.time()
tm = time.gmtime(sec)

print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]")
