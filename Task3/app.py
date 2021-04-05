from flask import Flask
from healthcheck import HealthCheck

app = Flask(__name__)

health = HealthCheck(app, "/healthy")
@app.route('/')
def hello_world():
    return 'Hello world'


if __name__ == '__main__':
    app.run(host='0.0.0.0')

health.add_check(hello_world)