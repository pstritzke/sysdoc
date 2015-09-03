#/bin/sh

valgrind --tool=memcheck --vgdb=full --vgdb-error=0 ./cpkg
