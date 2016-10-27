/*
 * This file is part of Freecell Solver. It is subject to the license terms in
 * the COPYING.txt file found in the top-level directory of this distribution
 * and at http://fc-solve.shlomifish.org/docs/distro/COPYING.html . No part of
 * Freecell Solver, including this file, may be copied, modified, propagated,
 * or distributed except according to the terms contained in the COPYING file.
 *
 * Copyright (c) 2016 Shlomi Fish
 */
/*
 * var_base_int.h - abstract/wrap either mpz_t or the faster unsigned __int128.
 */
#pragma once
#include "config.h"
#include "rinutils.h"

#ifdef FCS_USE_INT128_FOR_VAR_BASE

typedef unsigned __int128 fcs_var_base_int_t;
#define FCS_var_base_int__init(i)
#define FCS_var_base_int__set_ui(i, val) ((i) = (val))
#define FCS_var_base_int__left_shift(i, shift) ((i) <<= (shift))
#define FCS_var_base_int__add(i, i2) ((i) += (i2))
#define FCS_var_base_int__mod_div(i, i_mod, base)                              \
    (i_mod) = (i) % (base);                                                    \
    (i) /= (base)
#define FCS_var_base_int__get_ui(i) (i)
#define FCS_var_base_int__clear(i)
#define FCS_var_base_int__addmul_ui(i, i2, ui) ((i) += (i2) * (ui))
#define FCS_var_base_int__mul_ui(i, ui) (i) *= (ui)
#define FCS_var_base_int__not_zero(i) ((i) != 0)

#else /* FCS_USE_INT128_FOR_VAR_BASE */

/* Use GMP instead */

#include <gmp.h>

typedef mpz_t fcs_var_base_int_t;
#define FCS_var_base_int__init(i) mpz_init(i)
#define FCS_var_base_int__set_ui(i, val) mpz_set_ui((i), (val))
#define FCS_var_base_int__left_shift(i, shift) mpz_mul_2exp((i), (i), (shift))
#define FCS_var_base_int__add(i, i2) mpz_add((i), (i), (i2))
#define FCS_var_base_int__mod_div(i, i_mod, base)                              \
    mpz_fdiv_qr_ui(i, i_mod, i, base)
#define FCS_var_base_int__get_ui(i) mpz_get_ui(i)
#define FCS_var_base_int__clear(i) mpz_clear(i)
#define FCS_var_base_int__addmul_ui(i, i2, ui) mpz_addmul_ui(i, i2, ui)
#define FCS_var_base_int__mul_ui(i, ui) mpz_mul_ui((i), (i), (ui))
#define FCS_var_base_int__not_zero(i) (mpz_cmp_ui(i, 0) != 0)

#endif /* FCS_USE_INT128_FOR_VAR_BASE */