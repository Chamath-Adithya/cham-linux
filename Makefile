.PHONY: check package clean

check:
	bash tests/static.sh

package: check
	bash packaging/build.sh

clean:
	rm -rf build dist
