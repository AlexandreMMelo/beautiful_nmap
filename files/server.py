from flask import Flask, request, render_template,send_file

app = Flask(__name__, template_folder='')

@app.route('/<url>' , methods=['GET'])
def pages(url):
    
    return render_template(url)

@app.route('/')
def index():
    
    return render_template('index.html')

@app.route('/host.jpg')
def img():
    
    return send_file('host.jpg')
@app.route('/favicon.ico')
def fav():
    
    return send_file('favicon.ico')

if __name__ == "__main__":
    app.run( host = '0.0.0.0', port=1337)