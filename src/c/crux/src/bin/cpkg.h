#ifndef CPKG_H
#define CPKG_H

// Struct Port
struct sport {
    // Package Name
    char *name;
    // Version
    char *ver;
    // Release
    char *rel;

    // Pointer to next Port
    struct spackage *next;
};

// Struct Collection 
struct scoll {

    // Name
    char *name;
    // Description
    char *desc;
    // Host
    char *host;
    // Remote Collection
    char *coll;
    // Directory
    char *dir;
    // Configuration File
    char *filename;
    // Driver
    char *driver;

    // Pointer to next collection
    struct scoll *next;

    // Pointer to Head Port
    struct sport *port_head;
};

// Struct Configuration
struct spkg_conf { 
    // Source Directory
    char *src_dir;
    // Package Directory
    char *pkg_dir; 
    // Work Directory
    char *wrk_dir;
    // Pointer to Head Collection 
    struct scoll *coll_head;
};

#endif
