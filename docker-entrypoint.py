from subprocess import check_output, call
from requests import get
from os import getenv
from time import sleep


if __name__ == '__main__':
    print('Starting up')

    node_name = getenv('NODE_NAME')

    print('Watching for termination notice on node %s' % node_name)

    counter = 0

    while(True):
        response = get(
            "http://169.254.169.254/latest/meta-data/spot/termination-time"
        )
        if response.status_code == 200:
            kube_command = ['kubectl', 'drain', node_name,
                            '--grace-period=120', '--force',
                            '--ignore-daemonsets']

            print("Draining node: %s" % node_name)
            result = call(kube_command)
            if (result == 0):
                print('Node Drain successful')
                break

        else:
            if counter == 60:
                counter = 0
                print("Termination notice status: %s, on Node: %s" %
                      (response.status_code, node_name)
                      )
            counter += 5
            sleep(5)
