#include <stdio.h>
#include <stdlib.h>
#include <dirent.h> 
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "cpkg.h"
#include "conf.h"


int coll_dir_exists(char *dir, struct spkg_conf *pkg_conf){

    if(dir == NULL){
        abort();
    }

    pkg_conf->coll_curr = pkg_conf->coll_head;

    while(pkg_conf->coll_curr != NULL) {

        if(NULL != pkg_conf->coll_curr->dir  
        && 0 == strcmp(dir, pkg_conf->coll_curr->dir)) {
            return 1;
        }

        pkg_conf->coll_curr = pkg_conf->coll_curr->next;

    }

    return 0;
}

int parse_coll_conf(char *file, struct spkg_conf *pkg_conf) {


    int size = 0;
    char *value = NULL;

    FILE *fp;
    char line[256];

    char *wr_file = NULL;

    char *flag = NULL;
    char *name = NULL;
    char *driver = NULL;

    char *filename = NULL;

    char *host = NULL;
    char *dir = NULL;
    char *coll = NULL;
    char *desc = NULL;

    if((wr_file = strdup(file)) == NULL){
        abort();
    }

    name = strtok(wr_file, ".");
    driver = strtok(NULL, ".");
    flag = strtok(NULL, ".");

    if(flag != NULL){
        free(wr_file);
        return 1;
    }

    if(name == NULL || driver == NULL ){
        free(wr_file);
        return 1;
    }

    if(strcmp(driver, "httpup") != 0 && strcmp(driver, "rsync") != 0){
        free(wr_file);
        return 1;
    }

    size = strlen(PRT_DIR) + strlen(file) + 1;
    filename = xmalloc(size * sizeof(char));

    strcpy(filename, PRT_DIR);
    strcat(filename, file);

    fp = fopen(filename, "r");

    if(NULL == fp) {
        free(wr_file);
        free(filename);
        return 1;
    }

    while (fgets(line, sizeof(line), fp)) {

        size = valid_line(line);

        if(size < 0 || line[size] == '#'){
            continue;
        }
        
        value = get_value(HOST_RSYNC_PRT, line);
        if(NULL != value){
            host = value;
            continue;
        }
        
        value = get_value(COLL_RSYNC_PRT, line);
        if(NULL != value){
            coll = value;
            continue;
        }

        value = get_value(DEST_RSYNC_PRT, line);
        if(NULL != value){
            dir = value;
            continue;
        }

        value = get_value(HOST_HTTPUP_PRT, line);
        if(NULL != value){
            host = value;
            continue;
        }
        
        value = get_value(DEST_HTTPUP_PRT, line);
        if(NULL != value){
            dir = value;
            continue;
        }

    }

    fclose(fp);

    if(dir != NULL) { 

        if(coll_dir_exists(dir, pkg_conf)) {

            pkg_conf->coll_curr->name = strdup(name);
            pkg_conf->coll_curr->driver = strdup(driver);
            pkg_conf->coll_curr->host = host;
            pkg_conf->coll_curr->coll = coll;
            pkg_conf->coll_curr->filename = filename; 
 
            free(dir);
            free(wr_file);
            return 0;
        }
    }
   
    free(wr_file);
    free(filename);

    free(host);
    free(dir);
    free(coll);

    return 1;
}

int get_colls(struct spkg_conf *pkg_conf) {

    DIR *dp;
    struct dirent *dptr;

    dp = opendir(PRT_DIR);

    if(NULL == dp){
        abort();
    }

    pkg_conf->coll_curr = pkg_conf->coll_head;

    while ((dptr = readdir(dp)) != NULL) {

        if(dptr->d_name[0] == '.'){
            continue;
        }

        if(dptr->d_name[strlen(dptr->d_name) - 1] == '~'){
            continue;
        }

        parse_coll_conf(dptr->d_name, pkg_conf);

    } 

    closedir(dp);
    return 0;
}
