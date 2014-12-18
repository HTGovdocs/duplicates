duplicates
==========

Contains the basics for duplicate detection.

Startup
-------

You need to create an .env file in the root dir of this project, with (at least) the following variables set:

    db_driver = xx
    db_url    = xx
    db_user   = xx
    db_pw     = xx
    db_host   = xx
    db_name   = xx
    db_port   = xx

If missing, set up the database tables in /sql/hathi_gd.sql (https://github.com/HTGovdocs/duplicates/blob/master/sql/hathi_gd.sql).

In general, scripts are executed as such:

    cd /root/to/project/dir/;
    bundle exec ruby script/script_name.rb
