import lib/yaml/yaml/serialization

from posix_utils import sendSignal
from strutils    import parseInt, strip, splitLines, contains, Newlines
from streams     import newFileStream, close
from osproc      import startProcess, execCmdEx, poDaemon
from os          import getConfigDir, findExe, expandTilde, existsOrCreateDir, fileExists, commandLineParams

let args: seq[string] = commandLineParams()

let config_home: string = getConfigDir()
discard existsOrCreateDir(config_home & "dayemon")

let conf_file_yaml: string = config_home & "dayemon/init.yaml"
let conf_file_yml:  string = config_home & "dayemon/init.yml"

iterator countTo(n: int): int =
  var i = 0
  while i <= n:
    yield i
    inc i

type Daemon = object
  restart: bool
  name:    string
  opts:    string

var daemon_list: seq[Daemon]

proc has_pgrep(): bool =
  case findExe("pgrep", true, [""]):
    of "":
      result = false
    else:
      result = true

proc init(conf_file: string) =

  var yml = newFileStream(conf_file)
  load(yml, daemon_list)
  yml.close()

  for i in countTo(len(daemon_list) - 1):
    var idx: Daemon = daemon_list[i]

    var binpath: string = findExe(idx.name, true, [""])
    var options: string = expandTilde(idx.opts)
    var restart: bool   = idx.restart

    if restart == true:
      var pgrep = execCmdEx("pgrep " & idx.name)
      if pgrep.exitcode == 0:
        var pidstr: string = pgrep.output
        var pidstr2: string = strip(pidstr)

        if pidstr2.contains(Newlines):
          var pidarr = splitLines(pidstr2)
          for i in countTo(len(pidarr) - 1):
            sendSignal(int32(parseInt(pidarr[i])), 15)
        else:
          sendSignal(int32(parseInt(strip(pgrep.output))), 15)

      if options == "null":
        if binpath != "":
          discard startProcess(command = binpath, options={poDaemon})
      else:
        if binpath != "":
          discard startProcess(command = binpath, args = [options], options={poDaemon})

    else:
      if options == "null":
        if binpath != "":
          discard startProcess(command = binpath, options={poDaemon})
      else:
        if binpath != "":
          discard startProcess(command = binpath, args = [options], options={poDaemon})

proc main() =

  if has_pgrep() == false:
    stdout.write("you must have \x1B[3m\x1B[1mpgrep\x1B[0m installed to use dayemon.\n")
    quit(2)


  if len(args) == 1:

    let conffile: string = expandTilde(args[0])

    if fileExists(conffile):
      init(conffile)
      quit(0)

    else:
      stdout.write("specified config file was not found!\n")
      quit(2)

  elif len(args) > 1:
    stdout.write("too many arguments!\n")
    quit(2)

  else:

    if fileExists(conf_file_yaml):
      init(conf_file_yaml)
      quit(0)

    elif fileExists(conf_file_yml):
      init(conf_file_yml)
      quit(0)

    else:
      stdout.write("you are missing your configuration file!\nIt's path should be ~/.config/dayemon/init.yaml\n")
      quit(2)

main()
