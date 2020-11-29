-- This file must be setuid + owner = 0
term.clear()
term.setCursorPos(1, 1)
print(kernel.version() .. " " .. kernel.getHostName() .. " on tty" .. tostring(kernel.getvt()) .. "\n")
if fs.setPermissions == nil then error("This requires the Linux Kernel.") end
if users.getuid() ~= 0 then error("login must run as root user.") end
CCLog.default.consoleLogLevel = CCLog.logLevels.error
while true do
    kernel.setProcessProperty(_PID, "loggedin", false)
    write("Login: ")
    local uid = users.getUIDFromName(read())
    write("Password: ")
    local password = read("")
    if not users.checkPassword(uid, password) then print("Login incorrect\n") else
        kernel.setProcessProperty(_PID, "loggedin", true)
        users.setuid(uid)
        local oldDir = shell.dir()
        shell.setDir("~")
        print()
        shell.run("/etc/motd/motd.lua")
        shell.run("cash")
        shell.setDir(oldDir)
        kernel.setProcessProperty(_PID, "loggedin", false)
        term.clear()
        term.setCursorPos(1, 1)
        local ptab = kernel.getProcesses()
        local loggedin = false
        for k,v in pairs(ptab) do if v.loggedin and k ~= 1 then loggedin = true end end
        if loggedin == false then services.running = false end
        return
    end
end
