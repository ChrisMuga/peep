build-run:
	@ make build run -s
build:
	@ zig build
run:
	@ ./zig-out/bin/peep ./src
build-c:
	@ mkdir -p bin/c
	@ gcc -o bin/c/peep src/c/main.c
build-c-win:
	@ echo Building Windows target (C)
	@ gcc -o bin\c\peep src\c\main.c
run-c:
	@ ./bin/c/peep samples/input.txt
run-c-win:
	@ .\bin\c\peep samples\input.txt
build-odin:
	@ mkdir -p bin/odin
	@ odin build ./src/odin -out:bin/odin/peep -collection:utils=./src/odin/utils
build-odin-win:
	@ odin build ./src/odin -out:bin/odin/peep.exe -collection:utils=./src/odin/utils
run-odin:
	@ ./bin/odin/peep samples/input.txt:5
# Dry run C build
dry-c:
	@ make build-c -s
	@ ./bin/c/peep samples/input.txt 5:8
format:
	@ echo "Formatting all .zig files..."
	@ zig fmt ./
format-c:
	@ echo "Formatting C files in src/.."
	@ clang-format ./src/c/* -i --verbose
	@ echo "Done"
format-all:
	@ make format format-c -s;
clean-zig:
	@ echo "Clearing caches"
	@ rm -rf ~/.cache/zig .zig-cache zig-out
	@ echo "Done ✅"
clean-zig-win:
	@ echo "Clearing caches"
	@ del .zig-cache
	@ del zig-out
	@ echo "Done ✅"
show-docs:
	@ zig build-lib -femit-docs src/main.zig
	@ python3 -m http.server 8000 -d docs/
deploy:
	@ sudo echo "Building Zig release build..."
	@ zig build --release=small
	@ sudo cp zig-out/bin/peep ~/bin/
	@ echo "Copying binary \t\t ✅"
	@ sudo ln -sf ~/bin/peep /usr/local/bin/peep
	@ echo "Creating symlink \t ✅"
	@ echo "Done \t\t\t ✅"
deploy-c:
	@ sudo echo "Building C release build..."
	@ make build-c -s
	@ sudo cp bin/c/peep ~/bin/
	@ echo "Copying binary \t\t ✅"
	@ sudo ln -sf ~/bin/peep /usr/local/bin/peep
	@ echo "Creating symlink \t ✅"
	@ echo "Done \t\t\t ✅"
deploy-odin:
	@ sudo echo "Building Odin release build..."
	@ make build-odin -s
	@ sudo cp bin/odin/peep ~/bin/
	@ echo "Copying binary \t\t ✅"
	@ sudo ln -sf ~/bin/peep /usr/local/bin/peep
	@ echo "Creating symlink \t ✅"
	@ echo "Done \t\t\t ✅"
