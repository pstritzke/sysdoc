#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "cpkg.h"
#include "conf.h"
#include "coll.h"

int valid_dir(char *dir) {

    struct stat s = {0};
    if(!stat(dir, &s)) {
        if(s.st_mode & S_IFDIR) { 
            strlen(dir);

        }
    }
    return 0;
}

int valid_line(char* line) {

    int i = 0;

    while(line[i] != '\0' && (line[i] == ' ' || line[i] == '\t')) {
        i++;
    }

    if(line[i] == '\n') {
        return -1;
    }

    return i;
}

int get_value_pos(const char *str, char *line) {

    int str_size=0;

    str_size = strlen(str);
    if(strncmp(str, line, str_size) == 0){
        return str_size;
    }

    return 0;
}

char *get_value(const char *str, char *line) {

        size_t size;
        int pos = get_value_pos(str, line);

        if(pos > 0) {
            size = strlen(&line[pos]) - 1;
            return strndup(&line[pos], size); 
        }
        
        return NULL;
}


int parse_conf(struct spkg_conf *pkg_conf) {

    pkg_conf->src_dir = NULL;
    pkg_conf->pkg_dir = NULL;
    pkg_conf->wrk_dir = NULL;

    pkg_conf->coll_curr = NULL;
    pkg_conf->coll_head = NULL;

    parse_pkgmk_conf(pkg_conf);

    parse_prtget_conf(pkg_conf);

    get_colls(pkg_conf);

    get_ports(pkg_conf);

    return 0;  
}


int free_conf(struct spkg_conf *pkg_conf) {

    free(pkg_conf->src_dir);
    pkg_conf->src_dir = NULL;

    free(pkg_conf->pkg_dir);
    pkg_conf->pkg_dir = NULL;

    free(pkg_conf->wrk_dir);
    pkg_conf->wrk_dir = NULL;

    free_coll_list(pkg_conf);

    return 0;
}

int print_conf(struct spkg_conf *pkg_conf) {

    struct scoll *coll;

    printf("Source Dir: %s\n", pkg_conf->src_dir); 
    printf("Package Dir: %s\n", pkg_conf->pkg_dir); 
    printf("Work Dir: %s\n", pkg_conf->wrk_dir); 

    printf("\nCollections:\n\n");

    coll = pkg_conf->coll_head;

    while(coll != NULL){
        print_coll(coll);
        coll = coll->next;
    }

    return 0;

}
