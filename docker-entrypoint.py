from subprocess import call
from requests import get
from os import getenv
from time import sleep
import botocore.session


if __name__ == '__main__':
    print('Starting up')

    node_name = getenv('NODE_NAME')
    detach_elb = getenv('DETACH_ELB', 'False').lower() == 'true'

    instance_id = get(
        "http://169.254.169.254/latest/meta-data/instance-id"
    ).text
    region = get('http://169.254.169.254/latest/meta-data/placement/availability-zone').text[:-1]

    print('Watching for termination notice on node %s (region: %s, instance_id: %s, remove from ELB: %s)' \
        % (node_name, region, instance_id, detach_elb))
    session = botocore.session.get_session()
    client = session.create_client('elb', region_name=region)

    counter = 0
    while(True):
        try:
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
                else:
                    print('Node drain failed, will retry')
                    continue

                if not detach_elb:
                   continue

                print('Getting list of attached ELBs')
                lbs = client.describe_load_balancers()
                my_lbs = [lb['LoadBalancerName'] for lb in lbs['LoadBalancerDescriptions'] \
                    if instance_id in map(lambda i: i['InstanceId'], lb['Instances'])]
                for lb in my_lbs:
                    print("Removing instance from ELB: %s" % lb)
                    client.deregister_instances_from_load_balancer(
                        LoadBalancerName=lb,
                        Instances=[ { 'InstanceId': instance_id }, ]
                    )
            else:
                if counter == 60:
                    counter = 0
                    print("Termination notice status: %s, on Node: %s" % (response.status_code, node_name))
        except Exception as e:
            print("Drain request failed: %s" % e)
        finally:
                counter += 5
                sleep(5)

