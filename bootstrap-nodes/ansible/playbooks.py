
import glob
import os
import ansible_runner
from simple_term_menu import TerminalMenu

def main():
    playbook_name = ""
    inventory_path = os.path.join(os.path.dirname(__file__), "inventory.yaml")
    playbooks = glob.glob(os.path.join(os.path.dirname(__file__), "playbooks", "*.yaml"))

    for i in range(len(playbooks)):
        playbooks[i] = os.path.basename(playbooks[i])

    playbooks.sort()

    while playbook_name not in playbooks:
        terminal_menu = TerminalMenu(playbooks, title="Select a playbook to run:")
        menu_entry_index = terminal_menu.show()
        playbook_name = playbooks[menu_entry_index]

    playbook_path = os.path.join(os.path.dirname(__file__), "playbooks", playbook_name)
    job = ansible_runner.run(private_data_dir=os.path.dirname(__file__), playbook=playbook_path, inventory=inventory_path)
    print(f"Status: {job.status}")


if __name__=="__main__":
    main()