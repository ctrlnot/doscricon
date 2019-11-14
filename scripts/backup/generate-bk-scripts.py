import json
import datetime

purgatory_folder_name = '000'

with open('scripts/backup/config.json') as config_data:
  config = json.load(config_data)

  for folder, options in config.items():
    with open(f'scripts/backup/{folder}.sh', 'w') as script_file:
      bool_opts = []
      dest = options['dest']
      source = options['source']
      backup_dir = options['backupDir']

      if options.get('mirror'):
        bool_opts.append('--delete')
      elif options.get('removeSource'): # add only removeSource opts when the config isn't to mirror
        bool_opts.append('--remove-source-files')

      str_bool_opts = " ".join(bool_opts)
      str_bool_opts = f' {str_bool_opts}' if str_bool_opts else ''

      script_file.write('#!/bin/bash\n')

      script_file.write('\ntoday=$(date +"%Y%m%d")\n')

      script_file.write(f'\nrsync -avP{str_bool_opts} --backup --backup-dir="{backup_dir}/$today" "{source}/" "{dest}"\n')

      if options.get('hasPurgatory'):
        script_file.write(f'\nrsync -avP --delete --backup --backup-dir="{backup_dir}/$today/{purgatory_folder_name}" "{source}/{purgatory_folder_name}/" "{dest}/{purgatory_folder_name}"\n')

      if options['cleanVersions']:
        script_file.write(f'\ntarget="{backup_dir}"\n')
        script_file.write('lastMonth=$(date --date="-1 month" +"%Y%m%d")\n')
        script_file.write('fs=($(ls "$target"))\n')

        script_file.write('\nfor dirDate in "${fs[@]}"\n')
        script_file.write('do\n')
        script_file.write('  folder=$(basename "$dirDate")\n')
        script_file.write('  if [ $(date -d "$folder" +"%Y%m%d") -lt "$lastMonth" ]; then\n')
        script_file.write('    echo "Deleting Folder Version: $target/$folder"\n')
        script_file.write('    rm -r "$target/$folder"\n')
        script_file.write('  fi\n')
        script_file.write('done\n')
