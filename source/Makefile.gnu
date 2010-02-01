DEBUG = 0
PROFILE = 0
WITH_TRACES = 0
FREECELL_ONLY = 0
DISABLE_SIMPLE_SIMON := 0
WITHOUT_CARD_FLIPS := 0
WITH_LIBRB = 0
OPT_FOR_SIZE = 1
WITHOUT_CONTEXT_VAR := 0

COMPILER = gcc
# COMPILER = icc
# COMPILER = lcc
# COMPILER = pcc
# COMPILER = tcc
# COMPILER = tendra


ifeq ($(FREECELL_ONLY),1)
	DISABLE_SIMPLE_SIMON := 1
endif

CFLAGS := -Wall
GCC_COMPAT := 
INIT_CFLAGS := -Wp,-MD,.deps/$(*F).pp 

ifeq ($(COMPILER),gcc)
	CC = gcc
	GCC_COMPAT := 1
else ifeq ($(COMPILER),icc)
	CC = icc
	GCC_COMPAT := 1
else ifeq ($(COMPILER),sun)
	CFLAGS :=
	CC = cc
	GCC_COMPAT := 0
	INIT_CFLAGS :=
	CREATE_SHARED = $(CC) $(CFLAGS) -shared
	ifeq ($(OPT_FOR_SIZE),1)
		CFLAGS +=
	else
		CFLAGS += -fast
	endif
else ifeq ($(COMPILER),lcc)
	CC = lcc
	GCC_COMPAT := 1
else ifeq ($(COMPILER),pcc)	
	CC = pcc 
	GCC_COMPAT := 1
	CFLAGS += -I /usr/include/linux -I /usr/lib/gcc/i586-manbo-linux-gnu/4.3.2/include/
else ifeq ($(COMPILER),tcc)
	CC = tcc
	GCC_COMPAT := 1
else ifeq ($(COMPILER),tendra)
	CC = tcc
	CFLAGS := -Ysystem
	ifeq ($(DEBUG),1)
		CFLAGS += -g
	endif
	CREATE_SHARED = ld -shared
	END_SHARED := 	
else
	CC = error
endif

ifeq ($(GCC_COMPAT),1)
	CREATE_SHARED = $(CC) $(CFLAGS) -shared
	END_SHARED = $(END_LFLAGS) 
	ifeq ($(DEBUG),1)
		CFLAGS += -g
	else
		ifeq ($(OPT_FOR_SIZE),1)
			CFLAGS += -Os -fvisibility=hidden
		else
			CFLAGS += -O3 -march=pentium4 -fomit-frame-pointer
		endif
	endif
endif

END_SHARED += -ltcmalloc

ifneq ($(WITH_TRACES),0)
	CFLAGS += -DDEBUG
endif

ifneq ($(FREECELL_ONLY),0)
	CFLAGS += -DFCS_FREECELL_ONLY=1
endif

ifneq ($(DISABLE_SIMPLE_SIMON),0)
	CFLAGS += -DFCS_DISABLE_SIMPLE_SIMON=1
endif

ifneq ($(WITHOUT_CARD_FLIPS),0)
	CFLAGS += -DFCS_WITHOUT_CARD_FLIPPING=1
endif

ifeq ($(WITHOUT_CONTEXT_VAR),0)
	CFLAGS += -DFCS_WITH_CONTEXT_VARIABLE=1
endif


LFLAGS := $(CFLAGS)
END_LFLAGS := -lm

# Toggle for profiling information.
ifneq ($(PROFILE),0)
	END_OFLAGS := -pg
	END_LFLAGS := -pg -lc_p -lm_p -static-libgcc
endif

ifneq ($(WITH_LIBRB),0)
	END_LFLAGS += -lredblack
endif

DFLAGS = $(CFLAGS) -DDEBUG
END_DLFLAGS = $(END_LFLAGS)

DLFLAGS = $(LFLAGS)

FCS_SHARED_LIB = libfreecell-solver.so.0
TARGETS = fc-solve $(FCS_SHARED_LIB) \
          freecell-solver-range-parallel-solve \
          freecell-solver-multi-thread-solve \
          freecell-solver-fc-pro-range-solve

ifeq ($(EXIT),1)

error:
	@echo "Error! WHICH_STATE_ALLOCATION must be defined to a legal value"
	@echo $(LFLAGS)

else

all: $(TARGETS)

board_gen: dummy
	make -C board_gen/

dummy:



#<<<OBJECTS.START
OBJECTS :=                     \
          alloc.o             \
          app_str.o           \
          check_and_add_state.o \
          card.o              \
          cmd_line.o          \
          fcs_dm.o            \
          fcs_hash.o          \
          freecell.o          \
          instance.o          \
          lib.o               \
          move.o              \
		  move_funcs_maps.o   \
          move_funcs_order.o  \
          scans.o             \
		  split_cmd_line.o    \
          state.o             \


#>>>OBJECTS.END

ifeq ($(DISABLE_SIMPLE_SIMON),0)
	OBJECTS += simpsim.o
endif

ifeq ($(FREECELL_ONLY),0)
	OBJECTS += preset.o
endif

# MYOBJ.o ==> .deps/MYOBJ.P
DEP_FILES = $(addprefix .deps/,$(addsuffix .pp,$(basename $(OBJECTS))))

-include $(DEP_FILES)

%.o: %.c
	$(CC) $(INIT_CFLAGS) -c $(CFLAGS) -o $@ $< $(END_OFLAGS)

libfcs.a: $(OBJECTS)
	ar r $@ $(OBJECTS)
	ranlib $@

$(FCS_SHARED_LIB): $(OBJECTS)
	$(CREATE_SHARED) -o $@ $(OBJECTS) $(END_SHARED)
	if ! test -e libfreecell-solver.so ; then \
		ln -s $@ libfreecell-solver.so ; \
	fi

ifeq ($(COMPILER),tcc)
    LIB_LINK_PRE :=
else
    LIB_LINK_PRE := -Wl,-rpath,. 
endif

LIB_LINK_PRE += -L.
LIB_LINK_POST := -lfreecell-solver

fc-solve: main.o libfcs.a
	$(CC) $(LFLAGS) -o $@ $(LIB_LINK_PRE) $< $(LIB_LINK_POST) $(END_LFLAGS)

freecell-solver-range-parallel-solve: test_multi_parallel.o $(FCS_SHARED_LIB)
	$(CC) $(LFLAGS) -o $@ $(LIB_LINK_PRE) $< $(LIB_LINK_POST) $(END_LFLAGS)

freecell-solver-multi-thread-solve: threaded_range_solver.o $(FCS_SHARED_LIB)
	$(CC) $(LFLAGS) -o $@ $(LIB_LINK_PRE) $< $(LIB_LINK_POST) -lpthread $(END_LFLAGS)

FC_PRO_OBJS = fc_pro_range_solver.o fc_pro_iface.o

freecell-solver-fc-pro-range-solve: $(FC_PRO_OBJS) $(FCS_SHARED_LIB)
	$(CC) $(LFLAGS) -o $@ $(LIB_LINK_PRE) $(FC_PRO_OBJS) $(LIB_LINK_POST) $(END_LFLAGS)

clean:
	rm -f *.o $(TARGETS) libfcs.a test-lib mtest libfreecell-solver.so*

endif

%.show:
	@echo "$* = $($*)"
