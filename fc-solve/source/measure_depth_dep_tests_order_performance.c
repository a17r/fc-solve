/*
 * This file is part of Freecell Solver. It is subject to the license terms in
 * the COPYING.txt file found in the top-level directory of this distribution
 * and at http://fc-solve.shlomifish.org/docs/distro/COPYING.html . No part of
 * Freecell Solver, including this file, may be copied, modified, propagated,
 * or distributed except according to the terms contained in the COPYING file.
 *
 * Copyright (c) 2000 Shlomi Fish
 */
/*
 * measure_depth_dep_tests_order_performance.c - measure the relative
 * depth-dependent
 * performance of two scans.
 */
#include "rinutils.h"
#include "fcs_cl.h"
#include "range_solvers_gen_ms_boards.h"
#include "help_err.h"

static void print_help(void)
{
    printf("\n%s",
        "measure-depth-dep-tests-order-performance start end\n"
        "   [--args-start] [--args-end] [--output-to]\n"
        "[--scan1-to] [--scan2-to] [--iters-limit]\n"
        "[--max-ver-depth]"
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
        "     Limits each board for up to 'limit' iterations.\n");
}

typedef struct
{
    fcs_portable_time_t start_time, end_time;
    fcs_int_limit_t num_iters;
    int verdict;
} result_t;

static const char *known_parameters[] = {NULL};

static void set_tests_order(
    void *const instance, const int min_depth, const char *const moves_order)
{
#ifdef FCS_WITH_ERROR_STRS
    char *error_string;
#endif
    if (freecell_solver_user_set_depth_tests_order(
            instance, min_depth, moves_order FCS__PASS_ERR_STR(&error_string)))
    {
#ifdef FCS_WITH_ERROR_STRS
        fprintf(stderr, "Error! Got '%s'!\n", error_string);
        free(error_string);
#else
        fprintf(stderr, "%s\n", "depth-tests-order Error!");
#endif
        exit(-1);
    }
}

int main(int argc, char *argv[])
{
    /* char buffer[2048]; */
    fcs_int_limit_t iters_limit = 100000;
    int max_var_depth_to_check = 100;
#ifdef FCS_WITH_ERROR_STRS
    char *error_string;
#endif
    const char *scan1_to = NULL, *scan2_to = NULL;
    char *output_filename = NULL;

    int arg = 1, start_from_arg = -1, end_args = -1;

    if (argc < 3)
    {
        help_err("Not Enough Arguments!\n");
    }
    const_AUTO(start_board, atoi(argv[arg++]));
    const_AUTO(end_board, atoi(argv[arg++]));

    for (; arg < argc; arg++)
    {
        if (!strcmp(argv[arg], "--args-start"))
        {
            arg++;

            start_from_arg = arg;
            while (arg < argc)
            {
                if (!strcmp(argv[arg], "--args-end"))
                {
                    break;
                }
                arg++;
            }
            end_args = arg;
        }
        else if (!strcmp(argv[arg], "--output-to"))
        {
            if (++arg == argc)
            {
                help_err("--output-to came without an argument!\n");
            }
            output_filename = argv[arg];
        }
        else if (!strcmp(argv[arg], "--scan1-to"))
        {
            if (++arg == argc)
            {
                help_err("--scan1-to came without an argument!\n");
            }
            scan1_to = argv[arg];
        }
        else if (!strcmp(argv[arg], "--scan2-to"))
        {
            if (++arg == argc)
            {
                help_err("--scan1-to came without an argument!\n");
            }
            scan2_to = argv[arg];
        }
        else if (!strcmp(argv[arg], "--iters-limit"))
        {
            if (++arg == argc)
            {
                help_err("--iters-limit came without an argument!\n");
            }
            iters_limit = (fcs_int_limit_t)atol(argv[arg]);
        }
        else if (!strcmp(argv[arg], "--max-var-depth"))
        {
            if (++arg == argc)
            {
                help_err("--max-var-depth came without an argument!\n");
            }
            max_var_depth_to_check = atoi(argv[arg]);
        }
        else
        {
            fc_solve_err("Unknown argument - '%s'!\n", argv[arg]);
        }
    }

    if (!scan1_to)
    {
        fc_solve_err("--scan1-to not specified!\n");
    }

    if (!scan2_to)
    {
        fc_solve_err("--scan2-to not specified!\n");
    }

    if (!output_filename)
    {
        fc_solve_err("output filename not specified");
    }

    fc_solve_print_started_at();
    fflush(stdout);

    result_t *const results =
        SMALLOC(results, (size_t)(end_board - start_board + 1));

    FILE *const output_fh = fopen(output_filename, "wt");
    for (int min_depth_for_scan2 = 0;
         min_depth_for_scan2 < max_var_depth_to_check; min_depth_for_scan2++)
    {
        void *const instance = freecell_solver_user_alloc();

        if (start_from_arg >= 0)
        {
            freecell_solver_user_cmd_line_parse_args_with_file_nesting_count(
                instance, end_args, (freecell_solver_str_t *)(void *)argv,
                start_from_arg, known_parameters, NULL,
                NULL FCS__PASS_ERR_STR(&error_string), &arg, -1, NULL);
        }

        set_tests_order(instance, 0, scan1_to);
        set_tests_order(instance, min_depth_for_scan2, scan2_to);

        result_t *curr_result;
        int board_num;
        for (board_num = start_board, curr_result = results;
             board_num <= end_board; board_num++, curr_result++)
        {
            fcs_state_string_t state_string;
            get_board(board_num, state_string);

#ifndef FCS_WITHOUT_MAX_NUM_STATES
            freecell_solver_user_limit_iterations_long(instance, iters_limit);
#endif
            curr_result->start_time = fcs_get_time();

            curr_result->verdict =
                freecell_solver_user_solve_board(instance, state_string);

            curr_result->end_time = fcs_get_time();
            curr_result->num_iters =
                freecell_solver_user_get_num_times_long(instance);

            freecell_solver_user_recycle(instance);
        }

        freecell_solver_user_free(instance);

        printf("Reached depth %d\n", min_depth_for_scan2);

        fprintf(output_fh, "Depth == %d\n\n", min_depth_for_scan2);
        for (board_num = start_board, curr_result = results;
             board_num <= end_board; board_num++, curr_result++)
        {
            fprintf(output_fh, "board[%d].ret == %d\n", board_num,
                curr_result->verdict);
            fprintf(output_fh, "board[%d].iters == %ld\n", board_num,
                (long)curr_result->num_iters);

#define FPRINTF_TIME(label, field)                                             \
    fprintf(output_fh, "board[%d].%s = " FCS_T_FMT "\n", board_num, label,     \
        FCS_TIME_GET_SEC(curr_result->field),                                  \
        FCS_TIME_GET_USEC(curr_result->field));

            FPRINTF_TIME("start", start_time);
            FPRINTF_TIME("end", end_time);

#undef FPRINTF_TIME
        }
        fflush(output_fh);
    }

    fclose(output_fh);

    return 0;
}
