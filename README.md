# vim-oink
Run SQL straight from VIM

Are you `cat`ing raw SQL into the psql command?  Does your `[ "$EDITOR" == "vim" ]`? Then this is the vim plugin for you!

If you are using Postgres and you've saved your credentials in your workbench/editor, there is a good chance this plugin will already know all your passwords!  This plugin leverages `~/.pgpass` which is probably storing all your passwords in clear text.  Is that a good idea? Probably not, but it's going to be freaking sweet if this works!

To get started, copy the `*.vim` files from the `plugin` folder into your `.vim/plugin` directory.  Restart vim and try the following commands:

    :PgConnect

    :PgDatabases

    :PgTables

    :PgSchemas

Write some SQL in VIM and try the following:
    
    :PgExecBuf

    :PgExplainBuf

Make sure you have syntax highlighting on, and have a ball!


This expects that you have the `psql` executable installed on your machine.  Presently Postgres only, but expect this to expand to MySQL and friends.
