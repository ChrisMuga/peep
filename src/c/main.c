#include <stdio.h>
#include <stdlib.h>

#include "file.h"
#include "utils.h"

// NOTE: This C program can automatically pipe to nvim for example. Investigate
// 	- The zig program cannot do this out of the box

// TODO: Implement piping e.g. `git log | peep`
// TODO: Explain line for line to understand what's going on here...
// TODO: Show only line number, e.g `peep src/main.zig 14`
// TODO: Range of line numbers, e.g `peep src/main.zig 14-18`
// TODO: Script for debug and production/release builds
// TODO: peep --help
// TODO: Error handling in case:
//  - peep test.txt e (if line specifier A is invalid)
//  - peep test.txt 50:e (if line specifier B is invalid)
//  - peep test.txt 50-60 ("-" is an invalid delimiter)
//  - peep test.txt 50kk-60sk (either of the specifiers are not non-zero
//  numbers)

// ## Examples:
//     - ./bin/peep example.txt // To print the whole file
//     - ./bin/peep example.txt 14 // To print line 14 only
//     - ./bin/peep example.txt:14 // To print line 14 only
//     - ./bin/peep example.txt:14:15 // To print line 14 only
int main(int argc, char *argv[]) {
  if (argc <= 1) {
    handle_flag(FLAG_VERSION);
    echo("-----");
    handle_flag(FLAG_HELP);
    return 0;
  }

  char *range;
  int sln_a = -1;
  int sln_b = -1;

  char *file_name = argv[1];

  if (is_flag(file_name)) {
    handle_flag(file_name);
    return 0;
  }

  int is_folder = is_dir(file_name);

  if (is_folder) {
    printf("%s is a directory\n", file_name);
    printf("-------------\n");
    list_dir(file_name);
    printf("-------------\n");

    return 0;
  }

  if (has_char(file_name, ':')) {
    char **split_vars = split(file_name, ':');
    int len_split = len(split_vars);

    file_name = split_vars[0];

    if (len_split > 1) {
      sln_a = atoi(split_vars[1]);
    }

    if (len_split > 2) {
      sln_b = atoi(split_vars[2]);
    }

    free(split_vars);
  }

  if (argc > 1) {
    range = argv[2];
  }

  if (range != NULL) {
    int *x = split_range(range);

    if (x[0] != 0) {
      sln_a = x[0];
    }
    if (x[1] != 0) {
      sln_b = x[1];
    }
  }

  FILE *file = fopen(file_name, "r");

  if (file == NULL) {
    return printf("Error: Could not open file\n");
  }

  // Get file size
  fseek(file, 0L, SEEK_END);
  long size = ftell(file);

  if (sln_a == -1 && !is_folder) {
    printf("File size: %ld bytes\n", size);
  }

  char *buffer;

  buffer = (char *)malloc(size + 1);

  fseek(file, 0L, SEEK_SET);

  int i = 1;

  if (sln_a < sln_b) {
    printf("Printing L%d-L%d of %s\n", sln_a, sln_b, file_name);
    echo("--------------------");
  }

  while (fgets(buffer, size + 1, file)) {
    if (sln_a == -1) {
      printf("%d: \t %s", i, buffer);
    } else if (sln_a < sln_b && i >= sln_a && i <= sln_b) {
      printf("%d: \t %s", i, buffer);
    } else if (sln_a == i) {
      printf("========\n");
      printf("%d: %s", i, buffer);
      printf("========\n");
      break;
    }

    i = i + 1;
  }
  if (sln_a < sln_b) {
    echo("--------------------");
  }
  printf("\n");

  fclose(file);
}
