#include <dirent.h>
#include <string.h>
#include <sys/stat.h>

int is_dir(char *path) {
  struct stat buff;

  stat(path, &buff);

  return S_ISDIR(buff.st_mode);
}

// TODO: <List nested directories>
// 	- We need to obtain the full-path or absolute path, for every entry, so
// as to be able to use that fullpath to check if it is a dir or file, and
// subsequently list any files/directories if nested.
// 	- At this point we do not know which library/API to use for that.
void list_dir(char *path) {
  DIR *dir_ptr = opendir(path);

  int i = 0;

  while (dir_ptr) {
    struct dirent *ent_ptr = readdir(dir_ptr);

    if (ent_ptr == NULL) {
      return;
    }

    if (i > 1) {
      printf("%d\t %s\n", i - 1, ent_ptr->d_name);
    }

    i += 1;
  }

  printf("Reading %s\n", path);
}
