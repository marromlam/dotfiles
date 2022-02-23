import re

from kittens.tui.handler import result_handler
from kitty.fast_data_types import encode_key_for_tty
from kitty.key_encoding import KeyEvent, parse_shortcut

import kitty.conf.utils as ku
import kitty.key_encoding as ke
from kitty import keys


def main():
    pass


def actions(extended):
    yield keys.defines.GLFW_PRESS
    if extended:
        yield keys.defines.GLFW_RELEASE


def is_window_vim(window, vim_id):
    fp = window.child.foreground_processes
    return any(re.search(vim_id, p['cmdline'][0] if len(p['cmdline']) else '', re.I) for p in fp)


def handle_result(args, result, target_window_id, boss):
    w = boss.window_id_map.get(target_window_id)
    direction = args[2]
    key_mapping = args[3]
    vim_id = args[4] if len(args) > 4 else "n?vim"
    tab = boss.active_tab

    if w is None:
        return

    if w.screen.is_main_linebuf():
        getattr(tab, args[1])(args[2])
        return

    mods, key, is_text = ku.parse_kittens_shortcut(args[3])
    if is_text:
        w.send_text(key)
        return

    # if is_window_vim(w, vim_id):
    #     encoded = encode_key_mapping(key_mapping)
    #     w.write_to_child(encoded)
    # elif is_window_vim(w, "tmux"):
    if 1:
        extended = w.screen.extended_keyboard
        for action in actions(extended):
            sequence = (
                ('\x1b_{}\x1b\\' if extended else '{}')
                .format(
                    keys.key_to_bytes(
                        getattr(keys.defines, 'GLFW_KEY_{}'.format(key)),
                        w.screen.cursor_key_mode, extended, mods, action)
                    .decode('ascii')))
            w.write_to_child(sequence)
    else:
        boss.active_tab.neighboring_window(direction)


handle_result.no_ui = True


def encode_key_mapping(key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()

    return encode_key_for_tty(
        event.key, event.shifted_key, event.alternate_key, event.mods, event.action
    )


# @result_handler(no_ui=True)
# def handle_result(args, result, target_window_id, boss):
#     window = boss.window_id_map.get(target_window_id)
#     direction = args[2]
#     key_mapping = args[3]
#     vim_id = args[4] if len(args) > 4 else "n?vim"
# 
#     if window is None:
#         return
#     if is_window_vim(window, vim_id):
#         encoded = encode_key_mapping(key_mapping)
#         window.write_to_child(encoded)
#     else:
#         boss.active_tab.neighboring_window(direction)
