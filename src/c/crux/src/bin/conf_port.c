#include <stdio.h>
#include <stdlib.h>
#include <dirent.h> 
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "cpkg.h"
#include "conf.h"

int get_ports(struct spkg_conf *pkg_conf) {

    DIR *dp;
    struct dirent *dptr;

    pkg_conf->coll_curr = pkg_conf->coll_head;

    // Loop all ports
    while(pkg_conf->coll_curr != NULL) {

        dp = opendir(pkg_conf->coll_curr->dir);

        if(NULL == dp){
            pkg_conf->coll_curr = pkg_conf->coll_curr->next;
            continue;
        }
        
        // Loop all directories inside port directory
        while ((dptr = readdir(dp)) != NULL) {

            if(dptr->d_name[0] == '.'){
                continue;
            }

            if(dptr->d_name[strlen(dptr->d_name) - 1] == '~') {
                continue;
            }

            printf("Package: %s\n", dptr->d_name);

        }

        pkg_conf->coll_curr = pkg_conf->coll_curr->next;

    }

    return 0;

}
