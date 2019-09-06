from flask import Flask, request, render_template
import requests
import json
import os
import urllib.parse

app = Flask(__name__)

manager_ip = os.environ['MANAGER_IP']
base_url = 'http://'+manager_ip+'/v1.40'

@app.route('/')
def main():

    resp = requests.get(base_url+'/services')
    data = resp.json()
    services = []
    for element in data:
        tasks = []
        resp = requests.get(base_url+'/tasks?filters='+urllib.parse.quote(f"""{{"service":["{element['Spec']['Name']}"]}}""",safe=''))
        data_tasks = resp.json()
        for task in data_tasks:
            tasks.append({'id': task['ID']})
        services.append({'name': element['Spec']['Name'], 'id': element['ID'], 'tasks': tasks})
        
    return render_template('main.html',services=services)

@app.route('/logs/<type>/<id>')
def show_logs(type,id):

    if type == "service":
      endpoint = "services"
      resp = requests.get(base_url+'/'+endpoint+'/'+id)
      service = resp.json()

      if 'Spec' not in service:
        return 'No service with id '+id+' found'
      else:
        name = service['Spec']['Name']
    elif type == "task":
      endpoint = "tasks"
      resp = requests.get(base_url+'/'+endpoint+'/'+id)
      task = resp.json()
      
      if 'ID' not in task:
        return 'No task with id '+id+' found'
      else:
        name = task['ID']
    else:
        return 'Unsupported operation'

    resp = requests.get(base_url+'/'+endpoint+'/'+id+'/logs?stderr=1&stdout=1')
    logs = resp.text
    return render_template('logs.html',name=name,logs=logs,type=type)

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=8080,debug=True)
