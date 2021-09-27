import time

timesec = time.time()
tm = time.gmtime(timesec)


print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"list\" Command Detected")
print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"list\" Command Detected")
