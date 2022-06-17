import urllib.request
from io import StringIO
from flask import Flask, render_template, abort
import pandas as pd
from azure.storage.blob import ContainerClient

app = Flask(__name__)

blob_url = 'https://vdadlin.blob.core.windows.net/csvtable/us-500.csv'
conn_str="DefaultEndpointsProtocol=https;AccountName=vdadlin;AccountKey=MpdP8qfkZhz9MnTPWAFweHg4f0FP86j3MTLcyQ28l99c+OGHkIqii9pT4IQybq3UHNmdr5lJZ2Tw+AStYaikOQ==;EndpointSuffix=core.windows.net"
container_name="csvtable"

@app.route("/")
def sample_table():
    try:

        container_client=ContainerClient.from_connection_string(conn_str,container_name)
        blobs = container_client.list_blobs()
        blob_modified = 'unknown'

        for blob in blobs:
            if blob.name == 'us-500.csv':
                blob_modified = blob.last_modified.strftime('%d/%m/%y %H:%M:%S')
                break

        response = urllib.request.urlopen(blob_url).read()

    except Exception as e:
        abort(404)
        
    contents=str(response,'utf-8')
    sample_data = pd.read_csv(StringIO(contents))
    columns = sample_data.columns
    values = sample_data.values
    return render_template('table.html', columns=columns, values=values, title="SAMPLE DATA STAGE (last modified {})".format(blob_modified))

if __name__ == '__main__':
    app.run()