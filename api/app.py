import random
from flask import Flask, jsonify, request
app = Flask(__name__)
PORT = 8080
notes = []

@app.route("/")
def index():
    return "Welcome! This is a base server written in Python using the Flask framework."

@app.route("/api/notes", methods=["POST", "GET"])
def create_or_list_notes():
    if request.method == "POST":
        new_note = Note("Note no. " + str(random.randint(0, 999)), "Hello world!")
        notes.append(new_note)
    return jsonify([note.serialize() for note in notes])

class Note:
    def __init__(self, title, body):
        self.title = title
        self.body = body

    def serialize(self):
        return {
            "title": self.title,
            "body": self.body
        }

if __name__ == "__main__":
    app.run(port=PORT)