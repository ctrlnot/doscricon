Simple script for generating backup scripts using python and rsync. Made this to avoid uploading folder structure to git.

### Requirements:

- [Python 3.x](https://www.python.org/)
- [rsync](https://rsync.samba.org)

### Instructions:

- Create a `config.json` file then add these keys and values:
  ```
    {
      <filename>: {
        "source": <source folder file path (string)>,
        "dest": <dest folder file path (string)>,
        "backupDir": <folder path where the rsync will put the file versions (string)>,
        "cleanVersions": <true if want to delete the last month versions of files (boolean)>,
        "mirror": <true if dest will mirror source files (boolean)>,
        "removeSource": <true if rsync will remove source files on success (will not run if mirror config is true) (boolean)>,
        "purgatory": <folder where files are not yet officially added on backup or on review yet (string) put false if has none (boolean)>
      },
      ...
    }
  ```
- Run the `generate-bk-scripts.py`.
- Make the generated sh files executable `chmod +x {file}.sh`.
