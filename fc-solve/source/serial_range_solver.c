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
 * serial_range_solver.c - the Freecell Solver range solver.
 *
 * Also see:
 *  - fc_pro_range_solver.c - range solver that can count the moves in
 *  the solution and display the FC-Pro ones.
 *  - threaded_range_solver.c - solve different boards in several POSIX
 *  threads.
 */
#include "default_iter_handler.h"
#include "cl_callback_range.h"
#include "handle_parsing.h"
#include "trace_mem.h"
#include "help_err.h"

int main(int argc, char *argv[])
{
    long long total_num_iters = 0;
    fcs_bool_t was_total_iterations_limit_per_board_set = FALSE;
    fcs_int_limit_t total_iterations_limit_per_board = -1;
    binary_output_t binary_output = INIT_BINARY_OUTPUT;
    const char *solutions_directory = NULL;
    char *solution_fn = NULL;
    int arg = 1;

    if (argc < 4)
    {
        help_err("Not Enough Arguments!\n");
    }
    long long start_board = atoll(argv[arg++]);
    long long end_board = atoll(argv[arg++]);
    const long long stop_at = atoll(argv[arg++]);
    if (stop_at <= 0)
    {
        help_err("print_step (the third argument) must be greater than 0.\n");
    }

    for (; arg < argc; arg++)
    {
        if (!strcmp(argv[arg], "--binary-output-to"))
        {
            arg++;
            if (arg == argc)
            {
                help_err("--binary-output-to came without an argument!\n");
            }
            binary_output.filename = argv[arg];
        }
        else if (!strcmp(argv[arg], "--total-iterations-limit"))
        {
            arg++;
            if (arg == argc)
            {
                help_err(
                    "--total-iterations-limit came without an argument!\n");
            }
            was_total_iterations_limit_per_board_set = TRUE;
            total_iterations_limit_per_board = (fcs_int_limit_t)atol(argv[arg]);
        }
        else if (!strcmp(argv[arg], "--solutions-directory"))
        {
            arg++;
            if (arg == argc)
            {
                help_err("--solutions-directory came without an argument!\n");
            }
            solutions_directory = argv[arg];
            solution_fn =
                SMALLOC(solution_fn, strlen(solutions_directory) + 1024);
        }
        else
        {
            break;
        }
    }

    fc_solve_print_started_at();
    fflush(stdout);

    fc_solve_display_information_context_t display_context =
        INITIAL_DISPLAY_CONTEXT;
    void *const instance = alloc_instance_and_parse(argc, argv, &arg,
        known_parameters, cmd_line_callback, &display_context, TRUE);

    bin_init(&binary_output, &start_board, &end_board,
        &total_iterations_limit_per_board);

    if (was_total_iterations_limit_per_board_set)
    {
        freecell_solver_user_limit_iterations_long(
            instance, total_iterations_limit_per_board);
    }

    for (long long board_num = start_board; board_num <= end_board; board_num++)
    {
        fcs_state_string_t state_string;
        get_board(board_num, state_string);

        const int ret =
            freecell_solver_user_solve_board(instance, state_string);

        switch (ret)
        {
        case FCS_STATE_SUSPEND_PROCESS:
            fc_solve_print_intractable(board_num);
            print_int(&binary_output, -1);
            break;

        case FCS_STATE_FLARES_PLAN_ERROR:
#ifdef FCS_WITH_ERROR_STRS
            printf("Flares Plan: %s\n",
                freecell_solver_user_get_last_error_string(instance));
#else
            printf("%s\n", "Flares Plan Error");
#endif
            goto out_of_loop;

        case FCS_STATE_IS_NOT_SOLVEABLE:
            fc_solve_print_unsolved(board_num);
            print_int(&binary_output, -2);
            break;

        default:
            print_int(&binary_output,
                (int)freecell_solver_user_get_num_times_long(instance));
            break;
        }

        if (solutions_directory)
        {
            sprintf(solution_fn, "%s" FCS_LL9_FMT ".sol", solutions_directory,
                board_num);
            FILE *const output_fh = fopen(solution_fn, "wt");
            if (!output_fh)
            {
                fc_solve_err("Could not open output file '%s' for writing!",
                    solution_fn);
            }
            fc_solve_output_result_to_file(
                output_fh, instance, ret, &display_context);
            fclose(output_fh);
        }
        total_num_iters += freecell_solver_user_get_num_times_long(instance);

        if (board_num % stop_at == 0)
        {
            fc_solve_print_reached(board_num, total_num_iters);
        }
        freecell_solver_user_recycle(instance);
        trace_mem(board_num);
    }
out_of_loop:

    freecell_solver_user_free(instance);
    bin_close(&binary_output);
    free(solution_fn);
    solution_fn = NULL;

    return 0;
}