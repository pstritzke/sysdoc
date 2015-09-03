#include <stdio.h>
#include <stdlib.h>
//#include <dirent.h> 
#include <string.h>
#include "cpkg.h"
#include "conf.h"

int parse_pkgmk_conf(struct spkg_conf *pkg_conf) {

    FILE *fp;

    char line[256];

    int pos=0;
    int size=0;

    fp = fopen(PKGMK_CONF_FILE, "r");

    if(NULL == fp) {
        abort();
    }

    while (fgets(line, sizeof(line), fp)) {

        pos = valid_line(line);

        if(pos < 0 || line[pos] == '#'){
            continue;
        }

        pos = get_value_pos(SRC_DIR_STR, &line[pos]);

        if(pos > 0) {

            pos++;
            size = strlen(&line[pos]) - 2;
            pkg_conf->src_dir = strndup(&line[pos], size);
            if(!valid_dir(pkg_conf->src_dir)) {
                free(pkg_conf->src_dir);
                pkg_conf->src_dir = NULL;
                continue;
            }

        }

        pos = get_value_pos(WRK_DIR_STR, &line[pos]);

        if(pos > 0){

            pos++;
            size = strlen(&line[pos]) - 2;

            while(line[pos+size] != '$'){
                size--;
            }
            size--;

            pkg_conf->wrk_dir = strndup(&line[pos], size);
            if(!valid_dir(pkg_conf->wrk_dir)) {
                free(pkg_conf->wrk_dir);
                pkg_conf->wrk_dir = NULL;
                continue;
            }

        }

        pos = get_value_pos(PKG_DIR_STR, &line[pos]);

        if(pos > 0){

            pos++;
            size = strlen(&line[pos]) - 2;

            pkg_conf->pkg_dir = strndup(&line[pos], size); 
            if(!valid_dir(pkg_conf->pkg_dir)) {
                free(pkg_conf->pkg_dir);
                pkg_conf->pkg_dir = NULL;
                continue;
            }
        }       

    }

    return fclose(fp);

}
