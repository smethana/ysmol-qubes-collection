package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
)
var (
    arrApps = arr_cmd("ls /usr/share/applications /usr/share/xfce4/helpers/ | awk -F '.desktop' ' { print $1}' -")
    // for fedora add path "/usr/share/xfce4/helpers/"
    arrRunning = arr_cmd("pstree -T -N mnt | awk '/^  / {if (prev ~ /systemd|xinit/) {next} print prev; print $0} {prev=$0}'")
)
func arr_cmd(command string) []string {
    cmd := exec.Command("/bin/bash","-c",command)
    stdout, err := cmd.Output()
    if err != nil {
        fmt.Println(err.Error())
    }
    substrings := strings.Split(string(stdout), "\n")
    return substrings
}
func session_shutdown(fileName string) {
    file, err := os.OpenFile(fileName, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0666)
    if err != nil {
        fmt.Println("Error opening file:", err)
        return
    }
    defer file.Close()
    writer := bufio.NewWriter((file))
    for _, elem1 := range arrApps {
        for _, elem2 := range arrRunning {
            if strings.Contains(elem2, elem1) {
                // result = append(result, elem1)
                _, err := writer.WriteString(elem1+"\n")
                if err != nil {
                    fmt.Println("Error writing to file:", err)
                    return
                }
                break
            }
        }
    }
    // fmt.Println(result)
    err = writer.Flush()
    if err != nil {
        fmt.Println("Error flushing to file:", err)
    }
}
func session_startup(filename string) {
    file, err := os.Open(filename)
    if err != nil {
        fmt.Println("Error opening file:", err)
        return
    }
    defer file.Close()
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        // lines = append(lines, scanner.Text())
        cmd := exec.Command("/bin/bash","-c",scanner.Text())
        err := cmd.Start()
        if err != nil {
            fmt.Println("Error: %\n", err)
        }
    }
    if err := scanner.Err(); err != nil {
        fmt.Println("Error readin file:", err)
        return
    }
}
func main() {
    if len(os.Args) < 2 {
        fmt.Println("Usage: ./apps_session <arg> <filename>\n-shutdown -- for saving session\n-startup -- for resuming session")
        return
    }
    sysOption := string(os.Args[1])
    filename := string(os.Args[2])
    switch sysOption {
    case "-shutdown":
        session_shutdown(filename)
    case "-startup":
        session_startup(filename)
    default:
        fmt.Println("Are you dumb?")
        return
    }
}
func save_session() {
    // var result []string
    cmd := exec.Command("/bin/bash","-c","zenity --list --title=\"Save session?\" --column=\"Options\" \"save\" \"nah\"")
    stdout, err := cmd.Output()
    if err != nil {
        fmt.Println(err.Error())
    }
    changeDir := os.Chdir("/usr/local/bin")
    if changeDir != nil {
        fmt.Println("Error changing directory:", changeDir)
        return
    }
    choiceText := strings.TrimSpace(string(stdout))
    if string(choiceText) == "save" {
        session_shutdown("session.txt")
    } else {
        fmt.Println(choiceText)
    }
    
    fmt.Println("fuck you, but you did it, girlllll1!1!!1!111")
}
