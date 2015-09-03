#ifndef PORTS_H
#define PORTS_H
/*
 * Get Ports that are activated in prt-get
 */
int port_get(struct spkg_conf *pkg_conf);
int port_new(char *dir, struct spkg_conf *pkg_conf);
int port_free(struct sport *port);
int port_print(struct sport*);
int port_dir_exists(char *dir, struct spkg_conf *pkg_conf);

#endif
