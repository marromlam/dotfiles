# zoom_toggle
#
#

__all__ = []
__author__ = ["name"]
__email__ = ["email"]


def main(args):
    pass

from kittens.tui.handler import result_handler
@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    tab = boss.active_tab
    if tab is not None:
        if tab.current_layout.name == 'stack':
            tab.last_used_layout()
        else:
            tab.goto_layout('stack')


# vim: fdm=marker ts=2 sw=2 sts=2 sr noet
