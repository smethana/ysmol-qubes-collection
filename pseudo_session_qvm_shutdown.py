import argparse
import qubesadmin.tools
import os
parser = qubesadmin.tools.QubesArgumentParser()
parser.add_argument("first_arg")
args = parser.parse_args()
vm = str(args.first_arg)

def run_qvm_run(args):
    result=subprocess.run(
        ['python3', 
        '/usr/lib/python3.11/site-packages/qubesadmin/tools/qvm_run.py']+args,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    if result.returncode == 0:
        return result.stdout.strip()
    else:
        return f'error: {result.stderr.strip()}'

def process_string(output, keyword="Running now"):
    substrings = output.split(keyword)
    list_apps = substrings[0].split('\n')
    running_apps = substrings[1]
    match_made = set([e for e in list_apps if e in running_apps and e != ""])
    return match_made

def shutdown_sequence():
    arguments=['--pass-io', vm, 
    """ls /usr/share/applications /usr/share/xfce4/helpers 
    | awk -F '.desktop' '{ print $1 }' && echo 'Running now' && pstree -T -N mnt 
    | awk '/ / {if (prev ~ /systemd|xinit/) {next} print prev} {prev=$0}'"""]
    print prev; print $0} {prev=$0}
    output=run_qvm_run(arguments)
    result=process_string(output)
    subprocess.run("mkdir -p ~/.session", shell=True, check=True)
    directory = os.path.expanduser("~/.session")
    filepath = os.path.join(directory, vm)
    os.makedirs(directory, exist_ok=True)

    with open(filepath, 'w') as file:
        file.write("\n".join(result))
    subprocess.run(
        ['python3', 
        '/usr/lib/python3.11/site-packages/qubesadmin/tools/qvm_shutdown.py',
        vm],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    print('done')

def main():
    state=subprocess.run(
        ['python3', '/usr/lib/python3.11/site-packages/qubesadmin/tools/qvm_ls.py', 
        '--raw-data', 
        '--fields=STATE', 
        vm],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    if str(state.stdout) != "Running":
        shutdown_sequence()
        subprocess.run(['notify-send', 
                        'Session status', 
                        'Shutting down the qube and saving session applications'], 
                        check=True)
    else:
        subprocess.run(['notify-send', 
                        'Session status', 
                        'The qube is already shut down'], 
                        check=True)

if __name__ == "__main__":
    main()


