from flask import Flask, request, render_template
import requests_unixsocket
import json

app = Flask(__name__)

docker_socket_path = 'http+unix://%2Fvar%2Frun%2Fdocker.sock'

@app.route('/')
def main():
    session = requests_unixsocket.Session()
    resp = session.get(docker_socket_path+'/v1.40/containers/json')
    assert resp.status_code == 200

    data = resp.json()
    containers = []
    for element in data:
        containers.append({'name': element['Names'][0][1:], 'id': element['Id'][:12]})

    resp = session.get(docker_socket_path+'/v1.40/services')
    assert resp.status_code == 200

    data = resp.json()
    services = []
    for element in data:
        services.append({'name': element['Spec']['Name'], 'id': element['ID']})

    return render_template('main.html',containers=containers,services=services)

@app.route('/logs/containers/<container_id>')
def container_logs(container_id):
   session = requests_unixsocket.Session()

   resp = session.get(docker_socket_path+'/v1.40/containers/'+container_id+'/json')
   assert resp.status_code == 200
   container = resp.json()

   if 'Name' in container:
     resp = session.get(docker_socket_path+'/v1.40/containers/'+container_id+'/logs?stderr=1&stdout=1')
     assert resp.status_code == 200
     logs = resp.text
     return render_template('logs.html',type='container',name=container['Name'][1:],logs=logs)
   else:
     return 'No container with id '+container_id+' found'

@app.route('/logs/services/<service_id>')
def service_logs(service_id):
    session = requests_unixsocket.Session()

    resp = session.get(docker_socket_path+'/v1.40/services/'+service_id)
    assert resp.status_code == 200
    service = resp.json()

    if 'Spec' in service:
        resp = session.get(docker_socket_path+'/v1.40/services/'+service_id+'/logs?stderr=1&stdout=1')
        assert resp.status_code == 200
        logs = resp.text
        return render_template('logs.html',type='service',name=service['Spec']['Name'],logs=logs)
    else:
        return 'No service with id '+service_id+' found'

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=8080,debug=True)
