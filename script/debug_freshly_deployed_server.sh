#!/bin/sh

rm mimosa.db ; perl -Ilib script/mimosa_deploy.pl; DBIC_TRACE=1 perl script/mimosa_server.pl -rd -p 8080
