# testing

TEST_SCRIPTS=$(wildcard tests/test*.janet)

RUN="janet"

test: $(JANET_SCRIPTS)
	@for f in tests/test*.janet; do $(RUN) "$$f" || exit; done
