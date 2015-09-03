#include "coll.h"

struct scoll *malloc_coll() {

    struct scoll *coll = xmalloc(sizeof(struct scoll));

    coll->name = NULL;
    coll->desc = NULL;
    coll->host = NULL;
    coll->coll = NULL;
    coll->dir = NULL;
    coll->filename = NULL;
    coll->driver = NULL;

    ->next = NULL;

    ->pkg_head = NULL;
    ->pkg_curr = NULL;

    return coll;
}

int new_coll(char *dir, struct spkg_conf *pkg_conf) {

    size_t dir_size;
    struct scoll *coll;

    if(coll_dir_exists(dir, pkg_conf)){
        return 1;
    }

    if(0 == (dir_size = valid_dir(dir))) {
        return 1;
    }

    coll = malloc_coll();

    coll->dir = strndup(dir, dir_size);

    if(NULL == coll->dir){
        return 1;
    }

    if(NULL == pkg_conf->coll_head) {
        coll->next = NULL;
        pkg_conf->coll_head = coll;
        pkg_conf->coll_curr = coll;
        return 0;
    }

    pkg_conf->coll_curr = pkg_conf->coll_head;

    while (NULL != pkg_conf->coll_curr->next) {
        pkg_conf->coll_curr = pkg_conf->coll_curr->next;
    }

    coll->next = NULL;

    pkg_conf->coll_curr->next = coll;
    pkg_conf->coll_curr = coll;

    return 0;
}

int free_coll(struct scoll *coll){

        free(coll->name);
        coll->name = NULL;

        free(coll->desc);
        coll->desc = NULL;

        free(coll->host);
        coll->host = NULL;

        free(coll->coll);
        coll->coll = NULL;

        free(coll->dir);
        coll->dir = NULL;

        free(coll->filename);
        coll->filename = NULL;

        free(coll->driver);
        coll->driver = NULL;
        
        free(coll);

    return 0;
}

int free_coll_list(struct spkg_conf *pkg_conf) {

    pkg_conf->coll_curr = pkg_conf->coll_head;

    while(pkg_conf->coll_curr != NULL) {

        pkg_conf->coll_head = pkg_conf->coll_curr->next;

        free_coll(pkg_conf->coll_curr);
        
        pkg_conf->coll_curr = pkg_conf->coll_head;
    }

    return 0;
}

int print_colls(struct spkg_config *pkg_conf){

    struct scoll *coll;

    coll = pkg_conf->coll_head;

    while(coll != NULL){
        printf("%s\n", port->name);
        coll = coll->next;
    }

    return 0;

}

int print_coll(struct scoll *coll){

    printf("Collection: %s\n", port->name);
    printf("Dir:  %s\n", port->dir);
    printf("Description:  %s\n", port->desc);

    printf("Config:  %s\n", port->filename);
    printf("Driver:  %s\n", port->driver);
    printf("Host: %s\n", port->host);
    printf("Remote Collection: %s\n", port->coll);

}
