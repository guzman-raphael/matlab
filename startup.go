package main

import (
	"strings"
	"io/ioutil"
	"os"
	"strconv"
)

func main() {
	var user, uid, gid string = os.Getenv("MATLAB_USER"), os.Args[1], os.Args[2]
	var home string = "/home/" + user

	pass_byte, _ := ioutil.ReadFile("/etc/passwd")
	pass_str := string(pass_byte)
	pass_str = strings.Replace(
		pass_str, user + ":x:3000:3000", user + ":x:" + uid + ":" + gid, -1)
	pass_file, _ := os.Create("/etc/passwd")
	pass_file.WriteString(pass_str)
	pass_file.Close()

	group_byte, _ := ioutil.ReadFile("/etc/group")
	group_str := string(group_byte)
	group_str = strings.Replace(
		group_str, user + ":x:3000", user + ":x:" + uid, -1)
	group_file, _ := os.Create("/etc/group")
	group_file.WriteString(group_str)
	group_file.Close()

	uid_int, _ := strconv.Atoi(uid)
	gid_int, _ := strconv.Atoi(gid)
	os.Chown(home, uid_int, gid_int)
	os.Chown(home + "/.local", uid_int, gid_int)
	os.Chown(home + "/activate.ini", uid_int, gid_int)
}
