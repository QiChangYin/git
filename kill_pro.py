import os
import platform

system_type = ""
flag = ""


def kill_process_by_name(name,system_type):
    cmd = "ps %s | grep %s" % (flag, name)
    f = os.popen(cmd)
    txt = f.readlines()
    if len(txt) == 0:
        print("no process \"%s\"!!" % name)
        return
    else:
        for line in txt:
            column = line.split()
            if system_type == "x86_64":
                pid = column[1]
                cmd = "kill -9 %d" % int(pid)
                os.system(cmd)
            elif system_type == "armv7l":  # current TP architecture
                pid = column[2]
                cmd = "kill -9 %d" % int(pid)
                os.system(cmd)
                pid = column[0]
                cmd = "kill -9 %d" % int(pid)
                os.system(cmd)
            return

if __name__ == "__main__":
    process_name = ["kill_app_name.py"]
    system_type = platform.machine()
    if system_type == "x86_64":
        flag = "-aux"
    elif system_type == "armv7l":   # current TP architecture
        print("your computer is : " + system_type)
        flag = ""
    else:
        print("our project does not support the system of : " + system_type)
        exit()
    print("\nthe system message of your computer is:")
    print(platform.machine())
    print(platform.architecture()[0])
    print(platform.node())
    print(platform.system())
    print(platform.platform())
    print("the current processor is : ", system_type)
    has_pid = "python"
    cmd = "ps %s | grep %s" % (flag, has_pid)
    print("\nBefore you kill process :")
    os.system(cmd)
    for process in process_name:
        cmd = "killall %s" % (process)
        os.system(cmd)
        kill_process_by_name(process,system_type)
    cmd = "ps %s | grep %s" % (flag, has_pid)
    print("\nAfter you have killed the  process :")
    os.system(cmd)
