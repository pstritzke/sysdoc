#ifndef COLL_H
#define COLL_H

int coll_new(char *dir, struct spkg_conf*);
int coll_free(struct scoll*);

int free_coll_list(struct spkg_conf*);
int coll_print(struct spkg_conf*);
int print_coll(struct scoll*);

#endif
