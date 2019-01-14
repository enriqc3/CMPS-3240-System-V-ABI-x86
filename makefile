COMPILER=gcc
FLAGS=-Wall -O0

all: example_arguments

example_arguments:	example_arguments.c
	$(COMPILER) $(FLAGS) -S -o $@.s $<
