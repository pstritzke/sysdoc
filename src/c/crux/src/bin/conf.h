#ifndef CONF_H
#define CONF_H

#define PKGMK_CONF_FILE "/etc/pkgmk.conf"
#define PRT_DIR         "/etc/ports/"
#define PRT_CONF_FILE   "/etc/prt-get.conf"

#define SRC_DIR_STR     "PKGMK_SOURCE_DIR="
#define PKG_DIR_STR     "PKGMK_PACKAGE_DIR="
#define WRK_DIR_STR     "PKGMK_WORK_DIR="

#define PRT_DIR_STR     "prtdir "

#define HOST_RSYNC_PRT  "host="
#define HOST_HTTPUP_PRT "URL="

#define DEST_RSYNC_PRT  "destination="
#define DEST_HTTPUP_PRT "ROOT_DIR="

#define COLL_RSYNC_PRT  "collection="

//conf.c
/*
 * Loads pkgmk, prt-get.conf 
 * Only load ports configuration
 * that are defined in prt-get.conf
 */
int parse_conf(struct spkg_conf*);
int free_conf(struct spkg_conf*);
int print_conf(struct spkg_conf*);

int valid_dir(char *dir);
int valid_line(char* line);
int get_value_pos(const char *str, char *line);


// conf_pkmk.c 
int parse_pkgmk_conf(struct spkg_conf *pkg_conf);

// conf_prt.c
int parse_prtget_conf(struct spkg_conf *pkg_conf);

#endif

