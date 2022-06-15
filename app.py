from flask import Flask, render_template
import pandas as pd

app = Flask(__name__)

sample_data = pd.read_csv('us-500.csv')

@app.route("/")
def sample_table():
    columns = sample_data.columns
    values = sample_data.values
    return render_template('table.html', columns=columns, values=values, title="SAMPLE DATA")

if __name__ == '__main__':
    app.run()