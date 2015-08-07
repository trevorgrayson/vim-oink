" File:         postgres.vim
" Author:       Trevor Grayson
" Version:      0.1
" Description:  Rad ass SQL 'client' for Vim
"
"

function PgConnect()
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

  let databases = PgDatabases()
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

function PgSchemas()
  !echo "select schema_name from information_schema.schemata" | psql
endfunction

" presently this Buf.. should be able to pass a buffer
function PgExecBuf()
  set ft=sql
  let last_query = join(getline(1,'$'),' ')
  execute '!echo "' . last_query . '" | psql'
endfunction

function PgExplainBuf()
  set ft=sql
  let last_query = join(getline(1,'$'),' ')
  execute '!echo "EXPLAIN ' . last_query . '" | psql'
endfunction

function PgExecFile(sqlFile)
  "if sqlFile = filename
    "set ft=sql
  "endif
  let query = join(readfile(expand(('a'))),' ')
  execute '!echo "' . query . '" | psql'
endfunction

function PgDatabases()
  return split(system('echo "SELECT datname FROM pg_database;" | psql'),'\n')[3:-3] 
endfunction

function PgTables()
  return split(system('echo "\dt" | psql'),'\n')
endfunction

function PgExec()
  let query = s:get_visual_selection()
  execute '!echo "' . query . '" | psql'
endfunction

function PgExecHere()
  let query = s:get_visual_selection()
  let results =  split(system('echo "' . query . '" | psql'),'\n')
  call append( line('$'), results)
endfunction

command! -range PgExecHere call PgExecHere()
command! -range PgExec call PgExec()
command! PgConnect call PgConnect()
command! PgExecBuf call PgExecBuf()
command! PgDatabases echo join( PgDatabases(), "\n" )
command! PgTables echo join( PgTables(), "\n" )
command! PgSchemas call PgSchemas()
command! PgExplainBuf call PgExplainBuf()
command! -nargs=1 PgExecFile call s:PgExecFile(<f-args>)

function! s:get_visual_selection()
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, " ")
endfunction
