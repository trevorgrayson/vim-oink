" File:         postgres.vim
" Author:       Trevor Grayson
" Version:      0.1
" Description:  Rad ass SQL 'client' for Vim
"
"

function! MyConnect()
  let lines = readfile(expand(('~/.mypass')))
  let labels = []
  let i = 0
  for l in lines
    let labels += [i . '. ' . split(l,':')[0]]
    let i += 1
  endfor

  let choice = inputlist(labels)
  let $MYHOST = split(labels[choice])[1]
  let $MYUSER = split(lines[choice],':')[3]
  echom ' ...connecting to: ' . $MYHOST . ' as ' . $MYUSER

  let databases = PgDatabases()

  if len(databases) == 0
    echom "please set the database using :let $MYDATABASE=''"
    return
  endif

  " let dblabels = []
  " let i = 0
  " for d in databases
  "   let dblabels += [i . '. ' . d]
  "   let i += 1
  " endfor
  " let dbId = inputlist(dblabels)
  " let $MYDATABASE = substitute(databases[dbId], ' ','','')
  echom ' ...using ' . $MYDATABASE
endfunction

function! MySetUser(user)
  let $MYUSER = a:user
  let $MYSQL_BIN = '" | mysql -h ' . $MYHOST . ' -u ' . $MYUSER. ' ' . $MYDATABASE
endfunction

function! MySetDatabase(database)
  let $MYDATABASE = a:database
  let $MYSQL_BIN = '" | mysql -h ' . $MYHOST . ' -u ' . $MYUSER. ' ' . $MYDATABASE
endfunction

function! MySetHost(host)
  let $MYHOST = a:host
  let $MYSQL_BIN = '" | mysql -h ' . $MYHOST . ' -u ' . $MYUSER. ' ' . $MYDATABASE
endfunction

function! MySettings()
  let $MYHOST = input("Host:")
  let $MYUSER = input("User:")
  let $MYDATABASE = input("Database:")
  let $MYSQL_BIN = '" | mysql -h ' . $MYHOST . ' -u ' . $MYUSER . ' ' . $MYDATABASE
endfunction

function! MySchemas()
  !echo "select schema_name from information_schema.schemata" | mysql
endfunction

" presently this Buf.. should be able to pass a buffer
function! MyExecBuf()
  set ft=sql
  let last_query = join(getline(1,'$'),' ')
  execute '!echo "' . last_query . '" | mysql -h ' . $MYHOST . ' -u ' . $MYUSER
endfunction

function! MyExplainBuf()
  set ft=sql
  let last_query = join(getline(1,'$'),' ')
  execute '!echo "EXPLAIN ' . last_query . $MYSQL_BIN
endfunction

function! MyExecFile(sqlFile)
  "if sqlFile = filename
    "set ft=sql
  "endif
  let query = join(readfile(expand(('a'))),' ')
  execute '!echo "' . query . $MYSQL_BIN
endfunction

function! MyDatabases()
  return split(system('echo "SELECT datname FROM pg_database;" '. $MYSQL_BIN),'\n')[3:-3] 
endfunction

function! MyTables()
  return split(system('echo "\dt" ' . $MYSQL_BIN),'\n')
endfunction

function! MyExec()
  let query = s:get_visual_selection()
  execute '!echo "' . query . '" ' . $MYSQL_BIN
endfunction

function! MyStatus()
  echom "Host: " . $MYHOST
  echom "User: " . $MYUSER
  echom "Db:   " . $MYDATABASE
endfunction

function! MyExecHere()
  let query = s:get_visual_selection()
  let results = split(system('echo "' . query . $MYSQL_BIN),'\n')
  call append( line("'>"), results)
endfunction

command! -range MyExecHere call MyExecHere()
command! -range MyExec call MyExec()
command! MyConnect call MyConnect()
command! MyStatus  call MyStatus()
command! MyExecBuf call MyExecBuf()
command! MyDatabases echo join( MyDatabases(), "\n" )
command! MyTables echo join( MyTables(), "\n" )
command! MySchemas call MySchemas()
command! MyExplainBuf call MyExplainBuf()
command! MySettings call MySettings()
command! -nargs=1 MyExecFile call s:MyExecFile(<f-args>)

command! -nargs=1 MySetHost call MySetHost(<f-args>)
command! -nargs=1 MySetUser call MySetUser(<f-args>)
command! -nargs=1 MySetDatabase call MySetDatabase(<f-args>)

command! SS call 

function! s:get_visual_selection()
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, " ")
endfunction
