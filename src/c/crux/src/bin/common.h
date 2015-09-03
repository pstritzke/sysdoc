#ifndef CPKG_H
#define CPKG_H

// common.c
void *xmalloc(size_t size);

/* if is a valid directory
 * return strlen of *dir
 * else return 0
 */
int valid_dir(char *dir);
int valid_line(char* line);

/* Return 0 if str dont exist in line
 * or size of str
 */
int get_value_pos(const char *str, char *line);

#endif
