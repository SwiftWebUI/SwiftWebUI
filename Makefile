# Makefile

SWIFT_BUILD=swift build
SWIFT_CLEAN=swift package clean
SWIFT_BUILD_DIR=.build

all:
	$(SWIFT_BUILD)
	
clean :
	$(SWIFT_CLEAN)
	# We have a different definition of "clean", might be just Germany
	# pickyness.
	rm -rf $(SWIFT_BUILD_DIR) 
