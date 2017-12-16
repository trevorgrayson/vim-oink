" File:         postgres.vim
" Author:       Trevor Grayson
" Version:      0.1
" Description:  Rad ass SQL 'client' for Vim
"
"

function! OkConnect()
  let lines = readfile(expand(('~/.pgpass')))
  let labels = []
  let i = 0
  for l in lines
    let labels += [i . '. ' . split(l,':')[0]]
    let i += 1
  endfor

  let choice = inputlist(labels)
  let $PGHOST = split(labels[choice])[1]
  let $PGUSER = split(lines[choice],':')[3]
  echom ' ...connecting to: ' . $PGHOST . ' as ' . $PGUSER

  let databases = OkDatabases()

  if len(databases) == 0
    echom "please set the database using :let $PGDATABASE=''"
    return
  endif

  let dblabels = []
  let i = 0
  for d in databases
    let dblabels += [i . '. ' . d]
    let i += 1
  endfor
  let dbId = inputlist(dblabels)
  let $PGDATABASE = substitute(databases[dbId], ' ','','')
  echom ' ...using ' . $PGDATABASE

endfunction

function! OkSetUser(user)
  let $PGUSER = a:user
endfunction

function! OkSetDatabase(database)
  let $PGDATABASE = a:database
endfunction

function! OkSetHost(host)
  let $PGHOST = a:host
endfunction

function! OkSchemas()
  !echo "select schema_name from information_schema.schemata" | psql
endfunction

" presently this Buf.. should be able to pass a buffer
function! OkExecBuf()
  set ft=sql
  let last_query = join(getline(1,'$'),' ')
  execute '!echo "' . last_query . '" | psql'
endfunction

function! OkExplainBuf()
  set ft=sql
  let last_query = join(getline(1,'$'),' ')
  execute '!echo "EXPLAIN ' . last_query . '" | psql'
endfunction

function! OkExecFile(sqlFile)
  "if sqlFile = filename
    "set ft=sql
  "endif
  let query = join(readfile(expand(('a'))),' ')
  execute '!echo "' . query . '" | psql'
endfunction

function! OkDatabases()
  return split(system('echo "SELECT datname FROM pg_database;" | psql'),'\n')[3:-3] 
endfunction

function! OkTables()
  return split(system('echo "\dt" | psql'),'\n')
endfunction

function! OkExec()
  let query = s:get_visual_selection()
  execute '!echo "' . query . '" | psql'
endfunction

function! OkStatus()
  echom "Host: " . $PGHOST
  echom "User: " . $PGUSER
  echom "Db:   " . $PGDATABASE
endfunction

function! OkExecHere()
  let query = s:get_visual_selection()
  let results =  split(system('echo "' . query . '" | psql'),'\n')
  call append( line("'>"), results)
endfunction

command! -range OkExecHere call OkExecHere()
command! -range OkExec call OkExec()
command! OkConnect call OkConnect()
command! OkStatus  call OkStatus()
command! OkExecBuf call OkExecBuf()
command! OkDatabases echo join( OkDatabases(), "\n" )
command! OkTables echo join( OkTables(), "\n" )
command! OkSchemas call OkSchemas()
command! OkExplainBuf call OkExplainBuf()
command! -nargs=1 OkExecFile call s:OkExecFile(<f-args>)

command! -nargs=1 OkSetHost call OkSetHost(<f-args>)
command! -nargs=1 OkSetUser call OkSetUser(<f-args>)
command! -nargs=1 OkSetDatabase call OkSetDatabase(<f-args>)

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
