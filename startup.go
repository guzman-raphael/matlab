package main

import (
	"strings"
	"io/ioutil"
	"os"
	"strconv"
)

func main() {
	var old_user, user, uid, gid string = "muser", os.Getenv("MATLAB_USER"), os.Args[1], os.Args[2]
	var old_home string = "/home/" + old_user
	var old_matlab_home string = os.Getenv("MATLAB_INSTALLED_ROOT")

	pass_byte, _ := ioutil.ReadFile("/etc/passwd")
	pass_str := string(pass_byte)
	pass_str = strings.Replace(
		pass_str, old_user + ":x:3000:3000:Developer,,,:" + old_home, user + ":x:" + uid + ":" + gid + ":Developer,,,:" + old_home, -1)
	pass_file, _ := os.Create("/etc/passwd")
	pass_file.WriteString(pass_str)
	pass_file.Close()

	group_byte, _ := ioutil.ReadFile("/etc/group")
	group_str := string(group_byte)
	group_str = strings.Replace(
		group_str, old_user + ":x:3000", user + ":x:" + uid, -1)
	group_file, _ := os.Create("/etc/group")
	group_file.WriteString(group_str)
	group_file.Close()

	uid_int, _ := strconv.Atoi(uid)
	gid_int, _ := strconv.Atoi(gid)
	os.Chown(old_home, uid_int, gid_int)
	os.Chown(old_home + "/.local", uid_int, gid_int)
	os.Chown(old_home + "/.activate.ini", uid_int, gid_int)
	os.Chown(old_matlab_home + "/toolbox/local/pathdef.m", uid_int, gid_int)
}
