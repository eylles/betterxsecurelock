##############
# versioning #
##############

# version determined by git
GIT = $(shell git describe --tags 2>/dev/null || git rev-parse --short HEAD)
# last release tag
VERS = 0.0.0
# actual version number that will be used
VERSION = $(if $(GIT),$(GIT),$(VERS))
