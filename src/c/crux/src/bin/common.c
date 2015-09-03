#include <stdlib.h>
#include <sys/stat.h>
#include "cpkg.h"

void * xmalloc(size_t size) {
    // From ALP
    void *ptr = malloc(size);
    
    if(ptr == NULL){
        abort();
    } else {
        return ptr;
    }

}
