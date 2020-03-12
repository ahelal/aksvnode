#!/usr/bin/env python3
from flask import Flask
from flask import jsonify
import os
import threading
import time
from random import seed
from random import randint
from functools import reduce  # forward compatibility for Python 3
import operator
import requests
import pprint
seed(1)

app_name = os.environ["APP_NAME"]
port=os.environ.get("APP_PORT","5000")
app_services = os.environ.get("APP_SERVICES")
service_dns = os.environ.get("SERVICE_DNS", "default.svc.cluster.local")
app = Flask(app_name)

requests_connects = {}
response_connects = {}

def inc_dict(d, l1, l2=None):
    if l2 is None:
        if not d.get(l1):
            d[l1] = 1
        else:
            d[l1] += 1
    else:
        if not d.get(l1):
            d[l1] = {}
            d[l1][l2] = 1
        elif not d[l1].get(l2):
            d[l1][l2] = 1
        else:
            d[l1][l2] += 1
    return d

def connect_to_service():
    global requests_connects
    if app_services is None:
        print("-> No app services connection configured. will not connect to other services")
        return
    pp = pprint.PrettyPrinter(depth=6,width=1,compact=True)
    services = app_services.split(",")
    print("-> Connecting to services: {}".format(services), flush=True)
    while True:
        time.sleep(randint(10, 60))
        for service in services:
            if service_dns:
                url = "http://{}.{}/connect/{}".format(service,service_dns,app_name)
            else:
                url = "http://{}/connect/{}".format(service,app_name)
            success = False
            try:
                r = requests.get(url, timeout=2)
                if r.status_code == 200:
                    success = True
                else:
                    msg = "Status code not 200. {}".format(r.text)
            except Exception as e:
                msg = " Exception {}".format(e)

            if success:
                requests_connects = inc_dict(requests_connects, service, "success")
            else:
                print("-> pinging failure {}, {}".format(service,msg), flush=True)
                requests_connects = inc_dict(requests_connects, service, "failure")

        r = {"request":requests_connects, "response": response_connects}
        pstr = pp.pformat(r)
        print(pstr, flush=True)

@app.route("/connect/<connect_name>")
def connect(connect_name):
    global response_connects
    response_connects = inc_dict(response_connects, connect_name)
    return "OK", 200

@app.route("/")
def main():
    r = {"request":requests_connects, "response": response_connects}
    return jsonify(r), 200

if __name__ == "__main__":
    t = threading.Thread(target=connect_to_service)
    t.start()
    app.run(host='0.0.0.0',port=port)
