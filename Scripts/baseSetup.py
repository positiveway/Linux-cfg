from copy import copy

COMMENT_SYMBOL = '#'
HOME = '/home/user'


def _replace_config(line, configs_list, separator) -> str | None:
    line = line.strip()
    if separator in line and not line.startswith(COMMENT_SYMBOL):
        parts = line.split(separator)
        for config_name, config_value in configs_list.items():
            if config_name == parts[0]:
                del configs_list[config_name]
                return f'{config_name}{separator}{config_value}'

    return None


def _replace_configs(content_to_replace: str, file_name: str) -> None:
    separator = '='

    content_to_replace = content_to_replace.splitlines()
    comment = None
    if content_to_replace[0].startswith(COMMENT_SYMBOL):
        comment = content_to_replace[0]
        content_to_replace.pop(0)

    configs_list = {}
    for config in content_to_replace:
        config = config.split(separator)
        config_name = config[0]
        config_value = separator.join(config[1:])
        configs_list[config_name] = config_value

    with open(file_name) as file:
        lines = file.readlines()

    all_lines = {line.strip(): True for line in lines if line.strip()}

    processed_lines = []
    with open(file_name, 'w') as file:
        for line in lines:
            replacement = _replace_config(line, configs_list, separator)
            if replacement is not None:
                if comment is not None:
                    if comment not in all_lines:
                        processed_lines.append(comment)
                    comment = None
                processed_lines.append(replacement)
            else:
                processed_lines.append(line)

        if len(configs_list) != 0:
            processed_lines[-1] = processed_lines[-1] + '\n'

            if comment is not None:
                if comment not in all_lines:
                    processed_lines.append(comment)

            for config_name, config_value in configs_list.items():
                processed_lines.append(f'{config_name}{separator}{config_value}')

        for line in processed_lines:
            if not line.endswith('\n'):
                line += '\n'
            file.write(line)


def replace_configs(content_to_replace: str, file_name: str) -> None:
    content_to_replace = '\n'.join([line.strip() for line in content_to_replace.splitlines() if line.strip()])
    if COMMENT_SYMBOL in content_to_replace:
        blocks = content_to_replace.split(COMMENT_SYMBOL)
        blocks = [COMMENT_SYMBOL + block for block in blocks if block]
        for block in blocks:
            _replace_configs(block, file_name)
    else:
        _replace_configs(content_to_replace, file_name)


def comment_line(line_to_comment: str, file_name: str) -> None:
    with open(file_name) as file:
        lines = file.readlines()

    with open(file_name, 'w') as file:
        for line in lines:
            if line.strip().startswith(line_to_comment):
                line = f'{COMMENT_SYMBOL} {line}'

            if not line.endswith('\n'):
                line += '\n'
            file.write(line)


def main():
    replace_configs('''#Fix locale
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

    #Set formats
export LC_COLLATE=en_DE.UTF-8
export LC_MEASUREMENT=en_DE.UTF-8
export LC_MONETARY=en_DE.UTF-8
export LC_NUMERIC=en_DE.UTF-8
export LC_TIME=en_DE.UTF-8

    #Set scaling
export GDK_DPI_SCALE=1
export GDK_SCALE=2
export QT_SCALE_FACTOR=2
export XCURSOR_SIZE=64

    #Configure GTK
export GTK_CSD=0''', f"{HOME}/.profile")

    replace_configs('''GRUB_DEFAULT=saved
    GRUB_SAVEDEFAULT=true
    GRUB_TIMEOUT_STYLE=menu
    GRUB_TIMEOUT=20
    GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mitigations=off i915.enable_psr=0 nowatchdog nmi_watchdog=0 split_lock_detect=off zswap.enabled=0 systemd.zram=0"''',
                    '/etc/default/grub')

    comment_line('/swapfile', '/etc/fstab')


if __name__ == '__main__':
    main()
