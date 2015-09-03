#include <stdio.h>
#include <stdlib.h>
#include <dirent.h> 
#include <string.h>
#include "cpkg.h"
#include "conf.h"

int parse_prtget_conf(struct spkg_conf *pkg_conf) {

    char line[256];

    FILE *fp;

    int pos=0;
    int size=0;


    fp = fopen(PRT_CONF_FILE, "r");

    if(NULL == fp) {
        abort();
    }

    while (fgets(line, sizeof(line), fp)) {

        pos = valid_line(line);

        if(pos < 0 || line[pos] == '#'){
            continue;
        }

        pos = get_value_pos(PRT_DIR_STR, &line[pos]);

        if(pos > 0) {
            size = strlen(line) - 1;

            line[size] = '\0';

            new_port(&line[pos], pkg_conf);
        }
    }

    return fclose(fp);

}


