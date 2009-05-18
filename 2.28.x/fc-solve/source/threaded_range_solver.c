/* Copyright (c) 2000 Shlomi Fish
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
/*
 * TODO : Add a description of this file.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef WIN32
#include <sys/time.h>
#else
#include <sys/types.h>
#include <sys/timeb.h>
#endif
#include <pthread.h>
#ifndef WIN32
#include <unistd.h>
#endif

#include "fcs_user.h"
#include "fcs_cl.h"

#ifdef DMALLOC
#include "dmalloc.h"
#endif


struct microsoft_rand_struct
{
    long seed;
};

typedef struct microsoft_rand_struct microsoft_rand_t;

microsoft_rand_t * microsoft_rand_alloc(unsigned int seed)
{
    microsoft_rand_t * ret;

    ret = malloc(sizeof(microsoft_rand_t));
    ret->seed = (long)seed;

    return ret;
}

void microsoft_rand_free(microsoft_rand_t * rand)
{
    free(rand);
}

int microsoft_rand_rand(microsoft_rand_t * rand)
{
    rand->seed = (rand->seed * 214013 + 2531011);
    return (rand->seed >> 16) & 0x7fff;
}

typedef int CARD;

#define     BLACK           0               /* COLOUR(card) */
#define     RED             1

#define     ACE             0               /*  VALUE(card) */
#define     DEUCE           1

#define     CLUB            0               /*  SUIT(card)  */
#define     DIAMOND         1
#define     HEART           2
#define     SPADE           3

#define     SUIT(card)      ((card) % 4)
#define     VALUE(card)     ((card) / 4)
#define     COLOUR(card)    (SUIT(card) == DIAMOND || SUIT(card) == HEART)

#define     MAXPOS         21
#define     MAXCOL          9    /* includes top row as column 0 */

char * card_to_string(char * s, CARD card, int not_append_ws)
{
    int suit = SUIT(card);
    int v = VALUE(card)+1;

    if (v == 1)
    {
        strcpy(s, "A");
    }
    else if (v <= 10)
    {
        sprintf(s, "%i", v);
    }
    else
    {
        strcpy(s, (v == 11)?"J":((v == 12)?"Q":"K"));
    }

    switch (suit)
    {
        case CLUB:
            strcat(s, "C");
            break;
        case DIAMOND:
            strcat(s, "D");
            break;
        case HEART:
            strcat(s, "H");
            break;
        case SPADE:
            strcat(s, "S");
            break;
    }
    if (!not_append_ws)
    {
        strcat(s, " ");
    }


    return s;
}

char * get_board(int gamenumber)
{

    CARD    card[MAXCOL][MAXPOS];    /* current layout of cards, CARDs are ints */

    int  i, j;                /*  generic counters */
    int  wLeft = 52;          /*  cards left to be chosen in shuffle */
    CARD deck[52];            /* deck of 52 unique cards */
    char * ret;
    char * append_to;

    microsoft_rand_t * randomizer;


    ret = malloc(1024);
    ret[0] = '\0';

    /* shuffle cards */

    for (i = 0; i < 52; i++)      /* put unique card in each deck loc. */
    {
        deck[i] = i;
    }

    randomizer = microsoft_rand_alloc(gamenumber);            /* gamenumber is seed for rand() */
    for (i = 0; i < 52; i++)
    {
        j = microsoft_rand_rand(randomizer) % wLeft;
        card[(i%8)+1][i/8] = deck[j];
        deck[j] = deck[--wLeft];
    }

    microsoft_rand_free(randomizer);

    append_to = ret;

    {
        int stack;
        int c;

        char card_string[10];

        for(stack=1 ; stack<9 ; stack++ )
        {
            for(c=0 ; c < (6+(stack<5)) ; c++)
            {
                append_to += sprintf(append_to, "%s",
                    card_to_string(
                        card_string,
                        card[stack][c],
                        (c == (6+(stack<5)))
                    )
                );
            }
            append_to += sprintf(append_to, "%s", "\n");
        }
    }

    return ret;
}

struct fc_solve_display_information_context_struct
{
    int debug_iter_state_output;
    int freecells_num;
    int stacks_num;
    int decks_num;
    int parseable_output;
    int canonized_order_output;
    int display_10_as_t;
    int display_parent_iter_num;
    int debug_iter_output_on;
    int display_moves;
    int display_states;
    int standard_notation;
};

typedef struct fc_solve_display_information_context_struct fc_solve_display_information_context_t;

static void my_iter_handler(
    void * user_instance,
    int iter_num,
    int depth,
    void * ptr_state,
    int parent_iter_num,
    void * lp_context
    )
{
    fc_solve_display_information_context_t * context;
    context = (fc_solve_display_information_context_t*)lp_context;

    fprintf(stdout, "Iteration: %i\n", iter_num);
    fprintf(stdout, "Depth: %i\n", depth);
    if (context->display_parent_iter_num)
    {
        fprintf(stdout, "Parent Iteration: %i\n", parent_iter_num);
    }
    fprintf(stdout, "\n");


    if (context->debug_iter_state_output)
    {
        char * state_string =
            freecell_solver_user_iter_state_as_string(
                user_instance,
                ptr_state,
                context->parseable_output,
                context->canonized_order_output,
                context->display_10_as_t
                );
        printf("%s\n---------------\n\n\n", state_string);
        free((void*)state_string);
    }

#ifdef MYDEBUG
    {
        fcs_card_t card;
        int ret;
        char card_str[10];

        ret = fcs_check_state_validity(
            ptr_state_with_locations,
            context->freecells_num,
            context->stacks_num,
            context->decks_num,
            &card
            );

        if (ret != 0)
        {

            fcs_card_perl2user(card, card_str, context->display_10_as_t);
            if (ret == 3)
            {
                fprintf(stdout, "%s\n",
                    "There's an empty slot in one of the stacks."
                    );
            }
            else
            {
                fprintf(stdout, "%s%s.\n",
                    ((ret == 2)? "There's an extra card: " : "There's a missing card: "),
                    card_str
                );
            }
            exit(-1);
        }
    }
#endif
}

struct pack_item_struct
{
    fc_solve_display_information_context_t display_context;
    void * instance;
};

typedef struct pack_item_struct pack_item_t;


static int cmd_line_callback(
    void * instance,
    int argc,
    char * argv[],
    int arg,
    int * num_to_skip,
    int * ret,
    void * context
    )
{
    pack_item_t * item;
    fc_solve_display_information_context_t * dc;
    item = (pack_item_t * )context;
    dc = &(item->display_context);

    *num_to_skip = 0;

    if ((!strcmp(argv[arg], "-i")) || (!strcmp(argv[arg], "--iter-output")))
    {
        freecell_solver_user_set_iter_handler(
            instance,
            my_iter_handler,
            dc
            );
        dc->debug_iter_output_on = 1;
    }
    else if ((!strcmp(argv[arg], "-s")) || (!strcmp(argv[arg], "--state-output")))
    {
        dc->debug_iter_state_output = 1;
    }
    else if ((!strcmp(argv[arg], "-p")) || (!strcmp(argv[arg], "--parseable-output")))
    {
        dc->parseable_output = 1;
    }
    else if ((!strcmp(argv[arg], "-c")) || (!strcmp(argv[arg], "--canonized-order-output")))
    {
        dc->canonized_order_output = 1;
    }
    else if ((!strcmp(argv[arg], "-t")) || (!strcmp(argv[arg], "--display-10-as-t")))
    {
        dc->display_10_as_t = 1;
    }
    else if ((!strcmp(argv[arg], "-m")) || (!strcmp(argv[arg], "--display-moves")))
    {
        dc->display_moves = 1;
        dc->display_states = 0;
    }
    else if ((!strcmp(argv[arg], "-sn")) || (!strcmp(argv[arg], "--standard-notation")))
    {
        dc->standard_notation = 1;
    }
    else if ((!strcmp(argv[arg], "-sam")) || (!strcmp(argv[arg], "--display-states-and-moves")))
    {
        dc->display_moves = 1;
        dc->display_states = 1;
    }
    else if ((!strcmp(argv[arg], "-pi")) || (!strcmp(argv[arg], "--display-parent-iter")))
    {
        dc->display_parent_iter_num = 1;
    }
    else
    {
        fprintf(stderr, "Unknown option %s!\n", argv[arg]);
        exit(-1);
        return 0;
    }
    *num_to_skip = 1;
    return FCS_CMD_LINE_SKIP;
}

#define LIMIT_STEP 500
#if 0
#define total_iterations_limit_per_board 100000
#endif

static char * known_parameters[] = {
    "-i", "--iter-output",
    "-s", "--state-output",
    "-p", "--parseable-output",
    "-t", "--display-10-as-t",
    "-pi", "--display-parent-iter",
    NULL
    };

#define BINARY_OUTPUT_NUM_INTS 16

struct binary_output_struct
{
    FILE * file;
    char * buffer;
    char * buffer_end;
    char * ptr;
};

typedef struct binary_output_struct binary_output_t;

void print_int(binary_output_t * bin, int val)
{
    unsigned char * buffer = (unsigned char *)bin->ptr;
    int p;

    for(p=0;p<4;p++)
    {
        buffer[p] = (val & 0xFF);
        val >>= 8;
    }
    bin->ptr += 4;
    if (bin->ptr == bin->buffer_end)
    {
        fwrite(bin->buffer, 1, bin->ptr - bin->buffer, bin->file);
        fflush(bin->file);
        /* Reset ptr to the beginning */
        bin->ptr = bin->buffer;
    }
}

#define print_int_wrapper(i) { }

static void print_help(void)
{
    printf("\n%s",
"freecell-solver-range-parallel-solve start end print_step\n"
"   [--binary-output-to filename] [--total-iterations-limit limit]\n"
"   [fc-solve Arguments...]\n"
"\n"
"Solves a sequence of boards from the Microsoft/Freecell Pro Deals\n"
"\n"
"start - the first board in the sequence\n"
"end - the last board in the sequence (inclusive)\n"
"print_step - at which division to print a status line\n"
"\n"
"--binary-output-to   filename\n"
"     Outputs statistics to binary file 'filename'\n"
"--total-iterations-limit  limit\n"
"     Limits each board for up to 'limit' iterations.\n"
          );
}

int read_int(FILE * f, int * dest)
{
    unsigned char buffer[4];
    int num_read;

    num_read = fread(buffer, 1, 4, f);
    if (num_read != 4)
    {
        return 1;
    }
    *dest = (buffer[0]+((buffer[1]+((buffer[2]+((buffer[3])<<8))<<8))<<8));

    return 0;
}

static const pthread_mutex_t initial_mutex_constant =
    PTHREAD_MUTEX_INITIALIZER
    ;

static int next_board_num;
static int end_board;
static pthread_mutex_t next_board_num_lock;

typedef struct {
    int argc;
    char * * argv;
    int arg;
    int stop_at;
} context_t;

int total_iterations_limit_per_board = -1;

#ifndef WIN32
typedef long long very_long_int_t;
#else
typedef __int64 very_long_int_t;
#endif

very_long_int_t total_num_iters = 0;
static pthread_mutex_t total_num_iters_lock;

void * worker_thread(void * void_context)
{
    context_t * context;
    pack_item_t user;
    char * error_string;
    int arg;
    int parser_ret;
    int ret;
    char * * argv;
    int board_num;
    char * buffer;
    int stop_at;
#ifndef WIN32
    struct timeval tv;
    struct timezone tz;
#else
    struct _timeb tb;
#endif    
    long total_num_iters_temp = 0;

    context = (context_t *)void_context;
    arg = context->arg;
    argv = context->argv;
    stop_at = context->stop_at;

    user.instance = freecell_solver_user_alloc();

    parser_ret =
        freecell_solver_user_cmd_line_parse_args(
            user.instance,
            context->argc,
            argv,
            arg,
            known_parameters,
            cmd_line_callback,
            &user,
            &error_string,
            &arg
            );

    if (parser_ret == FCS_CMD_LINE_UNRECOGNIZED_OPTION)
    {
        fprintf(stderr, "Unknown option: %s", argv[arg]);
        goto ret_label;
    }
    else if (
        (parser_ret == FCS_CMD_LINE_PARAM_WITH_NO_ARG)
            )
    {
        fprintf(stderr, "The command line parameter \"%s\" requires an argument"
                " and was not supplied with one.\n", argv[arg]);
        goto ret_label;
    }
    else if (
        (parser_ret == FCS_CMD_LINE_ERROR_IN_ARG)
        )
    {
        if (error_string != NULL)
        {
            fprintf(stderr, "%s", error_string);
            free(error_string);
        }
        goto ret_label;
    }

    ret = 0;

    while (1)
    {
        pthread_mutex_lock(&next_board_num_lock);
        board_num = next_board_num++;
        pthread_mutex_unlock(&next_board_num_lock);

        if (board_num > end_board)
        {
            break;
        }

        buffer = get_board(board_num);

        freecell_solver_user_limit_iterations(user.instance, total_iterations_limit_per_board);

        ret =
            freecell_solver_user_solve_board(
                user.instance,
                buffer
                );

        free(buffer);


        if (ret == FCS_STATE_SUSPEND_PROCESS)
        {
#ifndef WIN32
            gettimeofday(&tv,&tz);
            printf("Intractable Board No. %i at %li.%.6li\n",
                board_num,
                tv.tv_sec,
                tv.tv_usec
                );
#else
            _ftime(&tb);
            printf("Intractable Board No. %i at %li.%.6i\n",
                board_num,
                tb.time,
                tb.millitm*1000
            );
#endif
            fflush(stdout);
            print_int_wrapper(-1);
        }
        else if (ret == FCS_STATE_IS_NOT_SOLVEABLE)
        {
#ifndef WIN32
            gettimeofday(&tv,&tz);
            printf("Unsolved Board No. %i at %li.%.6li\n",
                board_num,
                tv.tv_sec,
                tv.tv_usec
                );
#else
            _ftime(&tb);
            printf("Unsolved Board No. %i at %li.%.6i\n",
                board_num,
                tb.time,
                tb.millitm*1000
            );
#endif
            print_int_wrapper(-2);
        }
        else
        {
            print_int_wrapper(freecell_solver_user_get_num_times(user.instance));
        }

        total_num_iters_temp += freecell_solver_user_get_num_times(user.instance);
        if (total_num_iters_temp > 1000000)
        {
            pthread_mutex_lock(&total_num_iters_lock);
            total_num_iters += total_num_iters_temp;
            pthread_mutex_unlock(&total_num_iters_lock);
            total_num_iters_temp = 0;
        }

        if (board_num % stop_at == 0)
        {
            very_long_int_t total_num_iters_copy;

            pthread_mutex_lock(&total_num_iters_lock);
            total_num_iters_copy = (total_num_iters += total_num_iters_temp);
            pthread_mutex_unlock(&total_num_iters_lock);
            total_num_iters_temp = 0;

#ifndef WIN32
            gettimeofday(&tv,&tz);
            printf("Reached Board No. %i at %li.%.6li (total_num_iters=%lli)\n",
                board_num,
                tv.tv_sec,
                tv.tv_usec,
                total_num_iters_copy
                );
#else
            _ftime(&tb);
            printf(
#ifdef __GNUC__
                    "Reached Board No. %i at %li.%.6i (total_num_iters=%lli)\n",
#else
                    "Reached Board No. %i at %li.%.6i (total_num_iters=%I64i)\n",
#endif
                board_num,
                tb.time,
                tb.millitm*1000,
                total_num_iters_copy
            );
#endif
            fflush(stdout);
        }

        freecell_solver_user_recycle(user.instance);
    }

    pthread_mutex_lock(&total_num_iters_lock);
    total_num_iters += total_num_iters_temp;
    pthread_mutex_unlock(&total_num_iters_lock);

    freecell_solver_user_free(user.instance);

ret_label:
    return NULL;
}


int main(int argc, char * argv[])
{
    /* char buffer[2048]; */
    int stop_at;
#ifndef WIN32
    struct timeval tv;
    struct timezone tz;
#else
    struct _timeb tb;
#endif


    int num_workers = 3;
    pthread_t * workers;

    char * binary_output_filename = NULL;

    binary_output_t binary_output;

    int arg = 1, start_from_arg, idx, check;

    context_t context;

    next_board_num_lock = initial_mutex_constant;
    total_num_iters_lock = initial_mutex_constant;
    if (argc < 4)
    {
        fprintf(stderr, "Not Enough Arguments!\n");
        print_help();
        exit(-1);
    }
    next_board_num = atoi(argv[arg++]);
    end_board = atoi(argv[arg++]);
    stop_at = atoi(argv[arg++]);

    for (;arg < argc; arg++)
    {
        if (!strcmp(argv[arg], "--binary-output-to"))
        {
            arg++;
            if (arg == argc)
            {
                fprintf(stderr, "--binary-output-to came without an argument!\n");
                print_help();
                exit(-1);
            }
            binary_output_filename = argv[arg];
        }
        else if (!strcmp(argv[arg], "--total-iterations-limit"))
        {
            arg++;
            if (arg == argc)
            {
                fprintf(stderr, "--total-iterations-limit came without an argument!\n");
                print_help();
                exit(-1);
            }
            total_iterations_limit_per_board = atoi(argv[arg]);
        }
        else if (!strcmp(argv[arg], "--num-workers"))
        {
            arg++;
            if (arg == argc)
            {
                fprintf(stderr, "--num-workers came without an argument!\n");
                print_help();
                exit(-1);
            }
            num_workers = atoi(argv[arg]);
        }
        else
        {
            break;
        }
    }

    start_from_arg = arg;

    /* for(board_num=1;board_num<100000;board_num++) */
#ifndef WIN32
    gettimeofday(&tv,&tz);
    printf("Started at %li.%.6li\n",
        tv.tv_sec,
        tv.tv_usec
        );
#else
    _ftime(&tb);
    printf("Started at %li.%.6i\n",
        tb.time,
        tb.millitm*1000
        );
#endif
    fflush(stdout);

    if (binary_output_filename)
    {
        FILE * in;

        binary_output.buffer = malloc(sizeof(int) * BINARY_OUTPUT_NUM_INTS);
        binary_output.ptr = binary_output.buffer;
        binary_output.buffer_end = binary_output.buffer + sizeof(int)*BINARY_OUTPUT_NUM_INTS;


        in = fopen(binary_output_filename, "rb");
        if (in == NULL)
        {
            binary_output.file = fopen(binary_output_filename, "wb");
            if (! binary_output.file)
            {
                fprintf(stderr, "Could not open \"%s\" for writing!\n", binary_output_filename);
                exit(-1);
            }

            print_int_wrapper(next_board_num);
            print_int_wrapper(end_board);
            print_int_wrapper(total_iterations_limit_per_board);
        }
        else
        {
            long file_len;
#define read_int_wrapper(var) \
            {       \
                if (read_int(in, &var))  \
                {        \
                    fprintf(stderr, "%s", \
                        "Output file is too short to deduce the configuration!\n"    \
                           );     \
                    exit(-1);       \
                }       \
            }
            read_int_wrapper(next_board_num);
            read_int_wrapper(end_board);
            read_int_wrapper(total_iterations_limit_per_board);

            fseek(in, 0, SEEK_END);
            file_len = ftell(in);
            if (file_len % 4 != 0)
            {
                fprintf(stderr, "%s", "Output file has an invalid length. Terminating.\n");
                exit(-1);
            }
            next_board_num += (file_len-12)/4;
            if (next_board_num >= end_board)
            {
                fprintf(stderr, "%s", "Output file was already finished being generated.\n");
                exit(-1);
            }
            fclose(in);
            binary_output.file = fopen(binary_output_filename, "ab");
            if (! binary_output.file)
            {
                fprintf(stderr, "Could not open \"%s\" for writing!\n", binary_output_filename);
                exit(-1);
            }
        }
    }
    else
    {
        binary_output.file = NULL;
    }

    context.argc = argc;
    context.argv = argv;
    context.arg = start_from_arg;
    context.stop_at = stop_at;

    workers = malloc(sizeof(workers[0])*num_workers);

    for ( idx = 0 ; idx < num_workers ; idx++)
    {
        check = pthread_create(
            &workers[idx],
            NULL,
            worker_thread,
            &context
        );
    }

    /* Wait for all threads to finish. */
    for( idx = 0 ; idx < num_workers ; idx++)
    {
        pthread_join(workers[idx], NULL);
    }

#ifndef WIN32
            gettimeofday(&tv,&tz);
            printf("Finished at %li.%.6li (total_num_iters=%lli)\n",
                tv.tv_sec,
                tv.tv_usec,
                total_num_iters
                );
#else
            _ftime(&tb);
            printf(
#ifdef __GNUC__
                    "Finished at %li.%.6i (total_num_iters=%lli)\n",
#else
                    "Finshed at %li.%.6i (total_num_iters=%I64i)\n",
#endif
                tb.time,
                tb.millitm*1000,
                total_num_iters
            );
#endif

    free(workers);

    return 0;
}

