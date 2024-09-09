from flask import Flask
server = Flask(__name__)
PORT = 8080

@server.route("/")
def index():
    return "Welcome! This is a base server written in Python using the Flask framework."

if __name__ == "__main__":
    server.run(port=PORT)