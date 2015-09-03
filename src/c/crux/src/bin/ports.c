#include <stdio.h>
#include "cpkg.h"
#include "ports.h"

int print_ports(struct scoll *coll) {

    struct sport *port;
    port = coll->port_head;

    while(port != NULL){
        printf("%s\n", port->name);
        port = port->next;
    }

    return 0;
}
