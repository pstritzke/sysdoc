#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include "cpkg.h"
#include "conf.h"
#include "ports.h"

#define F_HELP   0
#define F_LIST   1
#define F_SEARCH 2

/* The name of this program.  */
const char* program_name;

/* Prints usage information for this program to STREAM (typically
   stdout or stderr), and exit the program with EXIT_CODE.  Does not
   return.  */

void print_usage (FILE* stream, int exit_code) {
    fprintf (stream, "Usage:  %s options [ inputfile ... ]\n", program_name);
    fprintf (stream,
            "  -h  --help                       Display this usage information.\n"
            "  -o  --output filename            Write output to file.\n"
            "  -v  --verbose                    Print verbose messages.\n"
            "  -l  --list collection            List ports of collection.\n"
            "  -s  --search name                Search port.\n");

    exit (exit_code);
}

/* Main program entry point.  ARGC conains number of argument list
   elements; ARGV is an array of pointers to them.  */
int main (int argc, char* argv[]) {

    struct spkg_conf pkg_conf;

    int next_option;

    /* A string listing valid short options letters.  */
    const char* const short_options = "ho:v:ls";

    /* An array describing valid long options.  */
    const struct option long_options[] = {
        { "help",       0, NULL, 'h' },
        { "output",     1, NULL, 'o' },
        { "verbose",    0, NULL, 'v' },
        { "list",       0, NULL, 'l' },
        { "s",          1, NULL, 's' },
        { NULL,         0, NULL, 0   }   /* Required at end of array.  */
    };

    /* The name of the file to receive program output, or NULL for
       standard output.  */      
    const char *output_filename = stdout;

    /* Whether to display verbose messages.  */
    int verbose = 0;

    int function = 0;
    char *value = NULL;

    /* Remember the name of the program, to incorporate in messages.
       The name is stored in argv[0].  */
    program_name = argv[0];

    do {
        next_option = getopt_long (argc, argv, short_options,
                long_options, NULL);

        switch (next_option) {

            case 'h':   /* -h or --help */
                /* User has requested usage information.  Print it to standard
                   output, and exit with exit code zero (normal termination).  */
                function = F_HELP;

            case 'o':   /* -o or --output */
                /* This option takes an argument, the name of the output file.  */
                output_filename = optarg;
                break;

            case 'v':   /* -v or --verbose */
                verbose = 1;
                break;

            case 'l':   /* -l or --list */
                value = optarg;
                function = F_LIST;
                break;

            case '?':   /* The user specified an invalid option.  */
                /* Print usage information to standard error, and exit with exit
                   code one (indicating abonormal termination).  */
                print_usage (stderr, 1);

            case -1:    /* Done with options.  */
                break;

            default:    /* Something else: unexpected.  */
                abort ();
        }
    }
    while (next_option != -1);

    /* Done with options.  OPTIND points to first non-option argument.
       For demonstration purposes, print them if the verbose option was
       specified.  */
    if (verbose) {
        int i;
        for (i = optind; i < argc; ++i) 
            printf ("Argument: %s\n", argv[i]);
    }

    /* The main program goes here.  */

    if(function > 0) {
        parse_conf(&pkg_conf);
        if(verbose) {
            print_conf(&pkg_conf);
        }
    }

    switch (function) {

        case F_LIST:
            if(NULL == value){
                print_colls(&pkg_conf);
            }
            break;

        case F_HELP:
        default:
            print_usage(stdout, 0);
    }

    free_conf(&pkg_conf);

    return EXIT_SUCCESS;
}
