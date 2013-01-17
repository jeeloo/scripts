
#tmpdir=$(shell mktemp -d /tmp/make.XXXXXXXX)

all: tmpdir := $(shell mktemp -d /tmp/make.XXXXXXXX)
all: print_variable recurse

print_variable: 
	@echo $(tmpdir)

recurse:
	@$(MAKE) tmpdir=$(tmpdir) print_variable
	@rm -rvf $(tmpdir)


